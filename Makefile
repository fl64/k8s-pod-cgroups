deploy:
	kubectl apply -k prober

undeploy:
	kubectl delete -k prober
