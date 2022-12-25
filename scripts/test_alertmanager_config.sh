#!/usr/bin/env bash

set -exuo pipefail


NS=metrics
LABEL=alertmanager=kube-prometheus-stack-alertmanager
POD=$(kubectl -n $NS get pods -l $LABEL -o jsonpath="{.items[0].metadata.name}")
kubectl -n "$NS" exec --stdin --tty "$POD" -- cat /etc/alertmanager/config/alertmanager.yaml | amtool check-config
