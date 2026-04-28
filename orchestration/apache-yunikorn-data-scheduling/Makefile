.PHONY: cluster-up cluster-down install-yunikorn apply-policies apply-workloads validate logs cleanup

cluster-up:
	bash scripts/bootstrap_kind.sh

cluster-down:
	kind delete cluster --name data-yunikorn

install-yunikorn:
	bash scripts/install_yunikorn.sh

apply-policies:
	kubectl apply -f manifests/namespaces.yaml
	kubectl apply -f manifests/priority-classes.yaml
	kubectl apply -f manifests/queue-config.yaml

apply-workloads:
	bash scripts/apply_workloads.sh

validate:
	bash scripts/validate_scheduling.sh

logs:
	kubectl logs -n yunikorn -l app=yunikorn-scheduler --tail=200

cleanup:
	bash scripts/cleanup.sh
