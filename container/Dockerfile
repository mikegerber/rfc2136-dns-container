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

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["/usr/sbin/healthcheck"]

VOLUME /var/bind/rfc2136-dns-container
EXPOSE 53/udp
EXPOSE 53
