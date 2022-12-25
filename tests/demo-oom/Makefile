SECRET_NAME_SLACK_WEBHOOK = "alertmanager-slack-webhook"
NS = demo-oom

apply:
	kubectl create ns $(NS) || true
	kubectl apply -f app.yaml
	kubectl -n $(NS) delete secret $(SECRET_NAME_SLACK_WEBHOOK) --ignore-not-found
	kubectl -n $(NS) create secret generic $(SECRET_NAME_SLACK_WEBHOOK) --from-literal=webhook=$(SLACK_WEBHOOK_URL)
	kubectl -n $(NS) apply -f alertmanager-config.yaml

status:
	kubectl -n $(NS) get alertmanagerconfigs -o yaml
	kubectl -n $(NS) get po

clean:
	kubectl delete ns $(NS) || true
