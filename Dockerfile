FROM abiosoft/caddy:0.10.10

RUN apk add --no-cache libcap \
 && setcap 'cap_net_bind_service=+ep' /usr/bin/caddy \
 && apk del libcap \
 && addgroup -S -g 8888 caddy \
 && adduser -S -u 8888 -D -H caddy \
 && mkdir -p \
   /etc/proxy \
   /etc/proxy.d \
   /etc/proxy.certs \
 && chown -R caddy:caddy \
   /srv \
   /etc/proxy \
   /etc/proxy.d \
   /etc/proxy.certs
COPY --chown=caddy Caddyfile /etc/proxy/Caddyfile
USER caddy
ENV ORIGIN="web:3000"
ENV CADDYPATH="/etc/proxy.certs"
ENV TLS="self_signed"
VOLUME /etc/proxy.d
VOLUME /etc/proxy.certs
# ENTRYPOINT from abiosoft/caddy: ["/usr/bin/caddy"]
CMD ["--conf", "/etc/proxy/Caddyfile", "--log", "stdout"]
