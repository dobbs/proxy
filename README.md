# dobbs/proxy

Minimal reverse proxy to enable TLS protection of an origin server.

Originally extracted from [an example of Federated Wiki].

Our multi-stage build starts with [abiosoft/caddy] building a custom
caddy with the jwt plugin.  Our final image is alpine:3.7 with a
non-root user and our custom `Caddyfile` and a couple volumes.

[an example of Federated Wiki]: https://github.com/dobbs/wiki-tls#readme
[abiosoft/caddy]: https://hub.docker.com/r/abiosoft/caddy

https://caddyserver.com/

# Usage

See example in `test/docker-compose.yml`

# Environment variables

`ORIGIN` (default: `web:3000`) names the host and port of the Origin Server.

`CADYPATH` (default: `/etc/proxy`) see volumes below.

`TLS` (default: `self_signed`) see https://caddyserver.com/docs/tls

# Volumes

`/etc/proxy.d` place to add extra Caddyfiles.  All files with a
`.caddyfile` suffix will be included before the default config.  This
is intended to allow a base domain to be forwarded to a default
service (defined by `ORIGIN`) while allowing subdomains to be directed
to other services.

`/etc/proxy` where auto-generated certs live.

# Other

My favorite features:
* both port 443 and 80 are forwarded to the origin server
* all domain and sub-domain names will be forwarded
* you can include other Caddyfiles to delegate a specific subdomain to a
  specific service
* auto-generated self-signed certificate for localhost development
* override the default Caddyfile to use LetsEncrypt on a public server
* recently added a relatively simple test case

# Development

We include a small collection of tests which conform to TAP.

``` bash
prove -v
# example results
t/proxy.t ..
1..8
ok - default config localtest.me
ok - Caddy default page
ok - default config subdomain.localtest.me
ok - Caddy default page
ok - override config localtest.me
ok - Caddy default page
ok - override config subdomain.localtest.me
ok - overriden page
ok
All tests successful.
Files=1, Tests=8,  6 wallclock secs ( 0.02 usr  0.00 sys +  1.76 cusr  0.51 csys =  2.29 CPU)
Result: PASS
```

### Notes to self:

Github and Dockerhub are configured to build master branch and tags.

``` bash
git tag -am "" 0.10.12
git push --tags
```

I've tried to keep the git and docker versions in step with the
version of Caddy that's packaged in the image.  There have been
changes in this build without changes in Caddy, in which case I
have tagged like this:

``` bash
git tag -am "" 0.10.10-note
git push --tags
```
