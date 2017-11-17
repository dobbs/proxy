FROM abiosoft/caddy:builder
ENV VERSION=0.10.10
ENV PLUGINS=jwt
RUN /bin/sh /usr/bin/builder.sh

FROM alpine:3.6
COPY --from=0 /install/caddy /usr/bin/caddy
RUN apk add --update --no-cache \
 openssh-client \
 libcap \
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
COPY Caddyfile /etc/proxy/Caddyfile
RUN chown caddy /etc/proxy/Caddyfile
USER caddy
ENV ORIGIN="web:3000"
ENV CADDYPATH="/etc/proxy.certs"
ENV TLS="self_signed"
VOLUME /etc/proxy.d
VOLUME /etc/proxy.certs
ENTRYPOINT ["/usr/bin/caddy"]
EXPOSE 80 443 2015
CMD ["--conf", "/etc/proxy/Caddyfile", "--log", "stdout"]
