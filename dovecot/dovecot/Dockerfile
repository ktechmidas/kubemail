FROM alpine
RUN apk add bash sqlite dovecot vim nano dovecot-sqlite
RUN mkdir /data
RUN mkdir /var/vmail/ && addgroup -g 1000 vmail && adduser -h /var/vmail -s /bin/false -u 1000 --disabled-password -G vmail vmail
EXPOSE 143
COPY conf.d/ /etc/dovecot/conf.d/
COPY dovecot-sql.conf.ext /etc/dovecot/
COPY auth-sql.conf.ext /etc/dovecot/conf.d/
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]