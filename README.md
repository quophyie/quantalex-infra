# Quantal  Infrastructure Config

## Setup

1. Create a folder to setup your project

```bash
$ mkdir myproject

$ cd myproject

```

2. Clone the scripts project ``https://github.com/quophyie/scripts.git``. It contains scripts
that are required by the ``Quantal Infrastructure`` project

```bash
$ git clone https://github.com/quophyie/scripts.git .
```

3. Clone this project 

```bash
$ git clone https://github.com/quophyie/quantalex-infra.git .

$ cd quantalex-infra

```

4. Run bin/setup

```bash
$ cd scripts/infra

$ bin/setup

```

The setup script will setup a few aliases for you and possibly some environment variables for
you of which the most important is **`INFRA_SCRIPTS_ROOT`** which points to the absolute path 
of ``Quantal Infrastructure`` project (i.e. **`myproject`** in this example). 

**LOOK OUT FOR MESSAGES OUTPUT BY THE SETUP SCRIPT **

You may be required to source a few files to complete the environment variable setup

5. Source **``~/.zshrc``** if you are using `ZSH` or source **``~/.bash_profile``** if you are using
**`bash`** as your shell

6. Source any files that the setup script instructs you to do



7. Test that all setup has worked correctly, run the infrastructure with the following alias

```bash
$ run_quantal_infra

```

Thats all folks!!

