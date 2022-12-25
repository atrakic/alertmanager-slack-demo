# alertmanager-slack-demo
A testing setup for AlertManager/Slack integration.
Uses `kube-prometheus-stack` chart as deployment.

[Architecture](https://github.com/prometheus/prometheus/tree/b7e978d25577692b78b0f939233b192cb381e8b6#architecture-overview)

## Requirments
- helm
- kubectl
- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [amtool](https://github.com/prometheus/alertmanager#amtool)

## Environment
`SLACK_WEBHOOK_URL` variable, eg. https://hooks.slack.com/services/XXXXXX/YYYYYY/ZZZZZZZ

## How to test this?
Just execute `make --always-make` and minikube cluster would be bootstrapped with AM + Prometheus custom setup.
After initial bootstrap is done, install demo apps ``make demo-install` which would trigger various types alarms on Slack channel.
When done with testing, use `make clean` to stop triggering further alarm events.
