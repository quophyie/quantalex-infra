FROM kong:latest

COPY plugins/ /plugins

# we change to root to build the plugin
USER root

RUN cd /plugins && luarocks make  kong-jwt-blacklist-check/jwt-blacklist-check-0.1.1-1.rockspec

# Change user back to the kong user

USER kong

EXPOSE 8000 8443 8001 7946