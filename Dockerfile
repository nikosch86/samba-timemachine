FROM alpine:latest

RUN apk add --no-cache samba-common-tools samba-server samba-client \
  avahi avahi-compat-libdns_sd avahi-tools \
  dbus \
  supervisor

# Do not announce everything
RUN rm /etc/avahi/services/*.service

RUN touch /etc/samba/lmhosts

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf

VOLUME ["/var/lib/samba", "/var/cache/samba", "/run/samba"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-e", "debug", "--configuration", "/etc/supervisord.conf"]
