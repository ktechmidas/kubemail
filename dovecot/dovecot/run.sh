#!/bin/bash
syslogd
touch /var/log/messages
ln -sf /proc/1/fd/1 /var/log/messages
dovecot
tail -f /dev/null