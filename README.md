# Welcome to KubeMail (Alpha)

## Introduction
This project is to run a full mailserver (webmail, rspam, postfix, dovecot) on Kubernetes, it *mostly* works as is although there are some design decisions that are better being revisited later on. It does however have sensible defaults

Note the YML files in the Kubernetes folder will pull from my personal repository, which I cannot guarantee the stability of. You're much better rebuilding the images locally (since your config should be different to mine)

## Secrets
Obviously I haven't uploaded my secrets here because that would be silly...
Secrets stored in mail-credentials are:
RELAYHOST
USER
PASS

If this is your first time using secrets, you'll need to base64 encode them first (echo -n "mypass" | base64) and look at the secretssample.yml file

## Pointers
* The ingress must come up first so it can save the TLS/KEY, this is in kubernetes/postfix but is the main ingress
* I'm running Longhorn so my PVC's are using that, you can change the storageclass name
* But note I haven't tried this on single-server cluster or RWO. Do let me know if it works though!

## Installation

* First thing to do is build the docker containers, clone the repository then change and build as needed
* Host the built containers on Docker Hub or your own private repository
* Update the kubernetes yaml files in kubestuff/ to point to your repository
* Bring up the kubestuff/postfix/ingress.yml
* Go into postfix-dply.yml and update the PASS environment variable, it must be an md5sum so if your password is firstpass you'd put b9313589eca257aaed154d3517ab7f0f into the field. On Linux you can use echo -n firstpass | md5sum to get the password
* In terms of services we need postfix submission (postfix-sub.yml), postfix on 25 (postfix-svc.yml) and both dovecot services (one is internal, one is external)
* All services use nodeport and a high port (30025,30587,30993)
* You'll need to load balance these, Postfix is already set up to receive traffic through an LB with proxy protocol

If you want to do it *without* a load balancer you'll need to remove these two lines from postfix main.cf before building the images, then route to the services through the ingress.

    postscreen_upstream_proxy_protocol = haproxy
    postscreen_upstream_proxy_timeout = 5s

## Early Alpha

This is a very early Alpha version, but everything is here and does work! Eventually we will have an installation script that will allow you to select options as well as an admin panel to add users

## So how do I add users?

Without the admin panel (WIP) you'll need to go into the postfix container and run the following:

    kubectl exec -it deployments/postfix -- bash
    NAME=albert
    DOMAIN=example.com
    PASS=echo -n "firstpass" | md5sum
    echo "INSERT INTO domain ( domain, description, transport ) VALUES ( '$DOMAIN', 'kt', 'virtual' );" |sqlite3 /data/postfix.sqlite
    echo "INSERT INTO mailbox ( username, password, name, maildir, domain, local_part ) VALUES ( '$NAME@$DOMAIN', '$PASS', '$NAME', '$DOMAIN/$NAME@$DOMAIN/', '$DOMAIN', '$NAME' );" |sqlite3 /data/postfix.sqlite
    echo "INSERT INTO alias ( address, goto, domain ) VALUES ( '$NAME@$DOMAIN', '$NAME@$DOMAIN', '$DOMAIN' );" |sqlite3 /data/postfix.sqlite