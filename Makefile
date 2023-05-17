.PHONY: default kind-up kind-down cilium-up cilium-upgrade contour-up gateway-api-up gateway-api-cilium demo-up

default:

kind-up:
	kind create cluster --config kind-proxyless.yaml
#	kind create cluster --config kind.yaml

kind-down:
	kind delete cluster --name proxyless

cilium-up:
	helm repo add cilium https://helm.cilium.io/
	helm install --kube-context kind-proxyless cilium cilium/cilium --version 1.13.2 --namespace kube-system -f cilium-proxyless.values.yaml
#	helm install --kube-context kind-proxyless cilium cilium/cilium --version 1.13.2 --namespace kube-system -f cilium.values.yaml

cilium-upgrade:
	helm upgrade --kube-context kind-proxyless cilium cilium/cilium --version 1.13.2 --namespace kube-system -f cilium-proxyless.values.yaml
#	helm upgrade --kube-context kind-proxyless cilium cilium/cilium --version 1.13.2 --namespace kube-system -f cilium.values.yaml

contour-up:
	helm install  --kube-context kind-proxyless contour oci://registry-1.docker.io/bitnamicharts/contour --namespace projectcontour --create-namespace -f contour.values.yaml

gateway-api-up:
	kubectl --context kind-proxyless apply -k gateway-api

gateway-api-cilium:
	kubectl --context kind-proxyless apply -k gateway-api-cilium

demo-up:
	kubectl --context kind-proxyless apply -k demo-app