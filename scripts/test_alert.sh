#!/usr/bin/env bash

set -exuo pipefail

amtool alert add \
  --annotation=runbook='http://runbook.biz' \
  --annotation=summary='This is just a test alert' \
  --annotation=description="Testing AM alert pattern match. Executed by: $(whoami)" \
  alertname=test \
  node=$RANDOM \
  job=amtool-test \
  severity=info \
  instance="$(minikube ip)" \
  gitrepo="$(git config --get remote.origin.url)" \
  --alertmanager.url=http://localhost:9093 --no-version-check --tls.insecure.skip.verify
