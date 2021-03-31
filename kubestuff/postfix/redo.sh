#!/bin/bash
kubectl delete -f postfix-dply.yml
sleep 2
kubectl apply -f postfix-dply.yml
