# K3s NodePort External Access Fix — Ubuntu 22.04 (192.168.0.170)

**Date:** 2026-03-19
**Server:** ubuntu2204 — 192.168.0.170
**K8s distro:** K3s v1.33.6+k3s1
**iptables backend:** iptables-legacy v1.8.7

---

## Problem

Kubernetes NodePort services (e.g. `postgres-svc` on port 30005, `busybox-http-service` on 30009,
`quantal-timber-merchants-ui` on 30011) could not be reached from external hosts on the LAN.
Connections from within the server itself (localhost) worked fine.

Symptoms:
- `nc -z 192.168.0.170 30005` from an external host timed out
- `nc -z 127.0.0.1 30005` from the server itself succeeded
- No firewall (UFW) was active; `ufw status` reported inactive
- iptables INPUT chain had policy ACCEPT with no blocking rules
- K3s services, pods, endpoints, and iptables NAT/DNAT rules were all correctly configured

---

## Investigation

### 1. Initial checks (all OK)

| Check                        | Result                                              |
|------------------------------|-----------------------------------------------------|
| K3s service                  | `active (running)` for 23h                          |
| postgres pod                 | `Running`, IP 10.42.0.3                             |
| postgres-svc                 | `NodePort 5432:30005/TCP`, Endpoints: `10.42.0.3:5432` |
| iptables NAT DNAT            | Correctly chains: `KUBE-NODEPORTS → KUBE-EXT → KUBE-SVC → KUBE-SEP → DNAT 10.42.0.3:5432` |
| UFW                          | Inactive                                            |
| `net.ipv4.ip_forward`        | `1` (enabled)                                       |
| iptables INPUT policy        | ACCEPT                                              |
| iptables FORWARD policy      | ACCEPT                                              |
| kube-router network policies | None defined (default allow-all)                    |

### 2. Discovered: Docker nftables FORWARD chain with policy DROP

The server has **both Docker and K3s** installed. They use **different firewall backends**:

- **K3s** uses `iptables-legacy` (kernel's legacy xt_tables API)
- **Docker** uses `nftables` (kernel's nf_tables API)

Both hook into the **same netfilter FORWARD hook at the same priority (filter)**. The Linux
kernel evaluates **all** chains at the same hook/priority — a packet must be accepted by
**every** chain to pass through. A DROP from **any** chain is final.

Docker's nftables `ip filter` table had:

```
table ip filter {
    chain FORWARD {
        type filter hook forward priority filter; policy drop;   ← THIS IS THE PROBLEM
        counter jump DOCKER-USER
        counter jump DOCKER-FORWARD
    }

    chain DOCKER-USER {
        # EMPTY — no user rules
    }

    chain DOCKER-FORWARD {
        counter jump DOCKER-CT          # only matches oifname "docker0"
        counter jump DOCKER-ISOLATION-STAGE-1
        counter jump DOCKER-BRIDGE      # only matches oifname "docker0"
        iifname "docker0" counter accept
    }
}
```

**All Docker chains only handle `docker0` traffic.** Any non-Docker forwarded traffic
(including all K3s pod traffic via `cni0`) fell through to the **policy DROP**.

### 3. Packet trace confirmed the diagnosis

Using `tcpdump -i any -nn "host 10.42.0.3 and port 5432"`:

```
# SYN arrives from external host, gets DNAT'd, forwarded to pod:
ens33    In  IP 192.168.0.140.61736 > 192.168.0.170.30005: Flags [S]
cni0     Out IP 10.42.0.1.40348 > 10.42.0.3.5432: Flags [S]

# Pod responds with SYN-ACK:
vetha... P   IP 10.42.0.3.5432 > 10.42.0.1.40000: Flags [S.]
cni0     In  IP 10.42.0.3.5432 > 192.168.0.140.61758: Flags [S.]

# SYN-ACK NEVER appears on ens33 — dropped by Docker's nftables FORWARD chain
```

The SYN-ACK from the pod (cni0 → ens33) was dropped because:
- `iifname "cni0"` did not match any Docker rule
- No other accept rule matched
- Default policy DROP applied

### 4. Why localhost worked

The kube-router pod firewall chain (`KUBE-POD-FW-*`) has a rule:

```
ACCEPT all -- 0.0.0.0/0 10.42.0.3 ADDRTYPE match src-type LOCAL
```

Traffic originating from the node itself is accepted before reaching the FORWARD chain,
bypassing the Docker nftables issue entirely.

---

## Fix

### Rules added to Docker's DOCKER-USER nftables chain

Docker's `DOCKER-USER` chain is the **recommended extension point** — Docker never modifies
it, so user rules persist across Docker restarts.

```bash
sudo nft add rule ip filter DOCKER-USER oifname "cni0" accept
sudo nft add rule ip filter DOCKER-USER ip daddr 10.42.0.0/16 accept
sudo nft add rule ip filter DOCKER-USER iifname "cni0" accept
```

| Rule                          | Purpose                                        |
|-------------------------------|-------------------------------------------------|
| `oifname "cni0" accept`      | Allow inbound traffic TO pods (external → cni0) |
| `ip daddr 10.42.0.0/16 accept` | Allow traffic to the pod CIDR                 |
| `iifname "cni0" accept`      | Allow return traffic FROM pods (cni0 → ens33)  |

After adding these rules, stale conntrack entries from failed connection attempts needed
to be flushed:

```bash
sudo conntrack -F
```

### Persistence across reboots

A systemd service was created to re-apply the rules after Docker starts:

**`/etc/docker-k3s-nftables-fix.sh`**:
```bash
#!/bin/bash
sleep 5
nft add rule ip filter DOCKER-USER oifname "cni0" accept 2>/dev/null
nft add rule ip filter DOCKER-USER ip daddr 10.42.0.0/16 accept 2>/dev/null
nft add rule ip filter DOCKER-USER iifname "cni0" accept 2>/dev/null
```

**`/etc/systemd/system/docker-k3s-nftables-fix.service`**:
```ini
[Unit]
Description=Fix Docker nftables rules for K3s NodePort access
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/etc/docker-k3s-nftables-fix.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enabled with:
```bash
sudo systemctl daemon-reload
sudo systemctl enable docker-k3s-nftables-fix.service
```

---

## Verification

After applying the fix and flushing conntrack:

```
$ nc -z -w5 192.168.0.170 30005 && echo OK    # postgres-svc       ✅
$ nc -z -w5 192.168.0.170 30009 && echo OK    # busybox-http       ✅
$ nc -z -w5 192.168.0.170 30011 && echo OK    # merchants-ui       ✅
```

Full TCP handshake confirmed via tcpdump on ens33 — SYN, SYN-ACK, and ACK all visible.

---

## Key Takeaway

Running **Docker and K3s on the same host** creates a conflict between Docker's nftables
firewall (FORWARD policy DROP) and K3s's iptables-legacy rules. The two backends coexist
in the kernel but operate independently — Docker's nftables DROP silently blocks all
non-Docker forwarded traffic, including Kubernetes pod traffic. The fix is to add explicit
accept rules to Docker's `DOCKER-USER` nftables chain for the K3s CNI interface and pod CIDR.

An alternative long-term solution is to remove Docker entirely and use K3s's built-in
containerd runtime, eliminating the nftables/iptables-legacy conflict.
