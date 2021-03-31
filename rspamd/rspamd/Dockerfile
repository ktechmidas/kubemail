FROM alpine
RUN apk add rspamd rspamd-proxy rspamd-controller bash redis
RUN mkdir /data
COPY run.sh /run.sh
COPY local.d/ /etc/rspamd/local.d/
COPY worker-controller.conf /etc/rspamd/
RUN chmod +x /run.sh
CMD ["/run.sh"]