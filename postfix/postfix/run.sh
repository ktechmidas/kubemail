#!/bin/bash

#Logs redirect to kube/docker logs
touch /var/log/messages
ln -sf /proc/1/fd/1 /var/log/messages
ln -sf /proc/1/fd/1 /var/log/mail.log
rsyslogd

#This will fail if you've done it before and it's on a PV, it's fine
mkdir /var/spool/virtualmailboxes/
echo "mail.$DOMAIN" > /etc/hostname
echo "127.0.0.2 mail.$DOMAIN" >> /etc/hosts
echo "virtualmail:x:1000:1000::/var/spool/virtualmailboxes:/sbin/nologin" >> /etc/passwd
echo "virtualmail:x:1000:" >> /etc/group
chmod 700 /var/spool/virtualmailboxes/
chown -R virtualmail:virtualmail /var/spool/virtualmailboxes/
rm -f /usr/lib/sendmail
ln -s /usr/sbin/sendmail /usr/lib/sendmail

FILE=/data/done.txt
if [ ! -e /data/done.txt ]; then
    cat /sqlite.dmp | sqlite3 /data/postfix.sqlite
    echo "INSERT INTO domain ( domain, description, transport ) VALUES ( '$DOMAIN', 'kt', 'virtual' );" |sqlite3 /data/postfix.sqlite
    echo "INSERT INTO mailbox ( username, password, name, maildir, domain, local_part ) VALUES ( '$NAME@$DOMAIN', '$PASS', '$NAME', '$DOMAIN/$NAME@$DOMAIN/', '$DOMAIN', '$NAME' );" |sqlite3 /data/postfix.sqlite
    echo "INSERT INTO alias ( address, goto, domain ) VALUES ( '$NAME@$DOMAIN', '$NAME@$DOMAIN', '$DOMAIN' );" |sqlite3 /data/postfix.sqlite
    touch /data/done.txt
fi
postmap /etc/postfix/blacklist
sed -i "s/{AWSUSER}/$AWSUSER/g" /etc/postfix/sasl_passwd
sed -i "s#{AWSPASS}#$AWSPASS#g" /etc/postfix/sasl_passwd
sed -i "s#{RELAYHOST}#$RELAYHOST#g" /etc/postfix/sasl_passwd
/usr/sbin/postfix start
tail -f /dev/null