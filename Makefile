MAKEFLAGS += --silent

ifndef SLACK_WEBHOOK_URL
$(error SLACK_WEBHOOK_URL is not set)
endif

NS ?= metrics

.PHONY: all status minikube install webhook uninstall test clean

all: minikube install test status
	true

install:
	INSTALL_DEBUG=true \
	GRAFANA=false \
	./scripts/$@.sh port-forward

status:
	echo "localhost:9090 - prometheus"
	echo "localhost:9093 - alertmanager"
	echo "localhost:3000 - grafana"
	echo
	kubectl get servicemonitors -A
	kubectl get prometheusrules -A
	kubectl get alertmanagerconfigs -A
	kubectl -n $(NS) get all
	kubectl -n $(NS) get pods -l "release=kube-prometheus-stack"
	which amtool &>/dev/null && kubectl -n $(NS) exec --stdin --tty alertmanager-kube-prometheus-stack-alertmanager-0 -- cat /etc/alertmanager/config/alertmanager.yaml | amtool check-config

alertmanager-config:
	kubectl -n $(NS) exec --stdin --tty alertmanager-kube-prometheus-stack-alertmanager-0 -- cat /etc/alertmanager/config/alertmanager.yaml
	#kubectl -n $(NS) exec --stdin --tty prometheus-kube-prometheus-stack-prometheus-0 -- cat /etc/prometheus/prometheus.yml
	#kubectl -n $(NS) describe prometheusrule kube-prometheus-stack-rule-name

uninstall:
	helm uninstall "kube-prometheus-stack" --namespace="$(NS)"
	killall kubectl &>/dev/null

webhook.py:
	python app/$@ &

minikube:
	echo "You are about to create demo cluster."
	echo "Are you sure? (Press Enter to continue or Ctrl+C to abort) "
	read _
	./scripts/$@.sh

DEMO = demo-cronjob demo-cpu demo-mem
demo-install:
	for dir in $(DEMO);do pushd tests/$$dir; make; popd; done

demo-clean:
	for dir in $(DEMO);do pushd tests/$$dir; make clean; popd; done

test:
	./scripts/test_*.sh

clean:
	echo "You are about to delete demo cluster."
	echo "Are you sure? (Press Enter to continue or Ctrl+C to abort) "
	read _
	minikube delete

-include include.mk
