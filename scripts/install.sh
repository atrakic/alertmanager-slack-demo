#!/bin/bash

set -eu

CHART_VERSION="v18.0.7"
CHART_NAME="kube-prometheus-stack"
CHART_REPO="prometheus-community"
CHART_URL="https://prometheus-community.github.io/helm-charts"
CHART_CRD_OPERATOR_VERSION="v0.50.0"
NAMESPACE="metrics"

# Add dependency chart repos
## helm repo add prometheus-community $CHART_URL
## helm repo update

CRD_FILES=(
  "monitoring.coreos.com_alertmanagerconfigs.yaml"
  "monitoring.coreos.com_alertmanagers.yaml"
  "monitoring.coreos.com_podmonitors.yaml"
  "monitoring.coreos.com_probes.yaml"
  "monitoring.coreos.com_prometheuses.yaml"
  "monitoring.coreos.com_prometheusrules.yaml"
  "monitoring.coreos.com_servicemonitors.yaml"
)

# install custom resources before installing/updating prometheus-stack
for line in "${CRD_FILES[@]}" ; do
  URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$CHART_CRD_OPERATOR_VERSION/example/prometheus-operator-crd/$line"
  kubectl apply -f "${URL}"
done

PROM_TEMPLATE=./config/prometheusrules-values.yaml
AM_TEMPLATE=./config/alertmanager-values.yaml

helm upgrade --install --wait ${CHART_NAME} "${CHART_REPO}/${CHART_NAME}" \
    --version=${CHART_VERSION} \
    --create-namespace \
    --namespace="$NAMESPACE" \
    -f "${PROM_TEMPLATE}" \
    -f "${AM_TEMPLATE}" \
    --set prometheus.ingress.enabled=true \
    --set alertmanager.enabled=true \
    --set alertmanager.ingress.enabled=true \
    --set alertmanager.ingress.hosts=\{"localhost"\} \
    --set alertmanager.config.global.slack_api_url="${SLACK_WEBHOOK_URL}" \
    --set grafana.enabled="${GRAFANA:-false}" \
    --set coreDNS.enabled=false \
    --set kubeDNS.enabled=true \
    --set kubeEtcd.enabled=false

kubectl -n $NAMESPACE rollout status daemonset kube-prometheus-stack-prometheus-node-exporter
kubectl -n $NAMESPACE rollout status statefulset alertmanager-kube-prometheus-stack-alertmanager
kubectl -n $NAMESPACE rollout status deploy kube-prometheus-stack-operator
test "$GRAFANA" && kubectl -n $NAMESPACE rollout status deployment kube-prometheus-stack-grafana || true

kubectl -n $NAMESPACE wait --for=condition=Ready pods --timeout=300s --all
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
sleep 1

if [ "$INSTALL_DEBUG" ]; then
  kubectl get AlertManager -A
  kubectl get Prometheus -A
  kubectl get ServiceMonitor -A
  kubectl get prometheusrules -A

  # Adj. timeinterval for faster alert state:
  kubectl -n $NAMESPACE patch prometheusrules kube-prometheus-stack-kubernetes-apps \
    --type json -p='[{"op":"replace", "path":"/spec/groups/0/rules/0/for", "value":"2m"}]'
  kubectl -n $NAMESPACE patch prometheusrules kube-prometheus-stack-kubernetes-apps \
    --type json -p='[{"op":"replace", "path":"/spec/groups/0/rules/1/for", "value":"2m"}]'
  kubectl -n $NAMESPACE patch prometheusrules kube-prometheus-stack-kubernetes-apps \
    --type json -p='[{"op":"replace", "path":"/spec/groups/0/rules/9/for", "value":"2m"}]'
  kubectl -n $NAMESPACE patch prometheusrules kube-prometheus-stack-kubernetes-apps \
    --type json -p='[{"op":"replace", "path":"/spec/groups/0/rules/11/for", "value":"2m"}]'
  kubectl -n $NAMESPACE patch prometheusrules kube-prometheus-stack-kubernetes-apps \
    --type json -p='[{"op":"replace", "path":"/spec/groups/0/rules/12/for", "value":"2m"}]'
  # kubectl -n metrics get prometheusrule kube-prometheus-stack-kubernetes-apps -o yaml

  which amtool &>/dev/null && kubectl -n $NAMESPACE exec --stdin --tty alertmanager-kube-prometheus-stack-alertmanager-0 -- cat /etc/alertmanager/config/alertmanager.yaml | amtool check-config
fi

if [ "$1" = "port-forward" ]; then
  killall kubectl &>/dev/null || true
  kubectl -n $NAMESPACE port-forward svc/kube-prometheus-stack-prometheus 9090 &>/dev/null &
  kubectl -n $NAMESPACE port-forward svc/kube-prometheus-stack-alertmanager 9093 &>/dev/null &
  test "$GRAFANA" && { kubectl -n $NAMESPACE port-forward svc/kube-prometheus-stack-grafana 3000:80 &>/dev/null &} || true
  echo "Started port-forward commands: "
  echo "localhost:9090 - prometheus"
  echo "localhost:9093 - alertmanager"
  test "$GRAFANA" && echo "localhost:3000 - grafana" || true
fi
