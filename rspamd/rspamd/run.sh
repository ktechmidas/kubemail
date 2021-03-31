#!/bin/bash
touch /var/log/messages
ln -sf /proc/1/fd/1 /var/log/rspamd/rspamd.log
syslogd
redis-server --daemonize yes
rspamd --insecure
tail -f /dev/null