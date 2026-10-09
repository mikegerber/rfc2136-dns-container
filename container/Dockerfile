FROM       alpine:3
MAINTAINER Mike Gerber <mike@mike-gerber.de>

RUN apk add --no-cache \
  bind \
  bind-tools \
  py3-jinja2 \
  py3-yaml

COPY root /

ENTRYPOINT ["/usr/sbin/entrypoint"]
CMD ["/usr/sbin/named", "-u", "named", "-g"]

VOLUME /var/bind/rfc2136-dns-container
EXPOSE 53/udp
EXPOSE 53
