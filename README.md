# dobbs/proxy

Minimal reverse proxy to enable TLS protection of an origin server.

Extracted from [an example of Federated Wiki].  Somewhat likely that
it's not yet general purpose; that it's coupled to assumptions from
that context.

It is basically [abiosoft/caddy] with a specific `Caddyfile`.

[an example of Federated Wiki]: https://github.com/dobbs/wiki-example-tls-friends#readme
[abiosoft/caddy]: https://hub.docker.com/r/abiosoft/caddy

https://caddyserver.com/

# Usage

``` yaml
version: '3'
services:
  proxy:
    image: dobbs/proxy
    ports:
      - "80:80"
      - "443:443"
  web:
    ports:
      - "3000:3000"
    ...
```

The `ORIGIN` environment variable names the host and port of the
Origin Server.  It's default value is `web:3000`.  So you can either
name your service `web` and have it listen on port 3000, or set
`ORIGIN` to something that fits your environment.

The default `Caddyfile` is located at `/etc/proxy/Caddyfile`.  It will
also include any files matching the pattern `/etc/proxy/*-Caddyfile`.

My favorite features:
* both port 443 and 80 are forwarded to the origin server
* all domain names will be forwarded
* you can include other Caddyfiles to delegate a subdomain to a
  specific service.
* auto-generated self-signed certificate for localhost development.
* override the default Caddyfile to use LetsEncrypt on a public server.
