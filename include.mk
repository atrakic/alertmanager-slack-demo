# kubectl -n metrics logs alertmanager-kube-prometheus-stack-alertmanager-0 config-reloader
# kubectl -n metrics logs prometheus-kube-prometheus-stack-prometheus-0
# kubectl -n metrics exec --stdin --tty prometheus-kube-prometheus-stack-prometheus-0 -- cat /etc/prometheus/rules/prometheus-kube-prometheus-stack-prometheus-rulefiles-0/metrics-kube-prometheus-stack-alertmanager.rules.yaml 
# promtool check rules alert.rules.yml
# kubectl -n metrics exec --stdin --tty prometheus-kube-prometheus-stack-prometheus-0 -- ls -laR /etc/prometheus/
