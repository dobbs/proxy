# dobbs/proxy

Minimal reverse proxy to enable TLS protection of an origin server.

Originally extracted from [an example of Federated Wiki].

We extend [abiosoft/caddy] by using a non-root user and providing
a specific `Caddyfile`.

[an example of Federated Wiki]: https://github.com/dobbs/wiki-example-tls-friends#readme
[abiosoft/caddy]: https://hub.docker.com/r/abiosoft/caddy

https://caddyserver.com/

# Usage

See example in `test/docker-compose.yml`

# Environment variables

`ORIGIN` (default: `web:3000`) names the host and port of the Origin Server.

`CADYPATH` (default: `/etc/proxy.certs`) see volumes below.

`TLS` (default: `self_signed`) see https://caddyserver.com/docs/tls

# Volumes

`/etc/proxy.d` place to add extra Caddyfiles.  All files with a
`.caddyfile` suffix will be included before the default config.  This
is intended to allow a base domain to be forwarded to a default
service (defined by `ORIGIN`) while allowing subdomains to be directed
to other services.

`/etc/proxy.certs` where auto-generated certs live.

# Other

My favorite features:
* both port 443 and 80 are forwarded to the origin server
* all domain names will be forwarded
* you can include other Caddyfiles to delegate a subdomain to a
  specific service.
* auto-generated self-signed certificate for localhost development.
* override the default Caddyfile to use LetsEncrypt on a public server.
* recently added a relatively simple test case
