NS=demo-webhook

apply:
	kubectl apply -f app.yaml
	kubectl -n $(NS) create secret generic alertmanager-example --from-file=alertmanager.yaml

status:
	kubectl -n $(NS) get secrets
	kubectl -n $(NS) get alertmanagerconfigs -o yaml
