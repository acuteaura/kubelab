.PHONY: default kind kind-down cilium ciliumgrade contour gateway-api gateway-api-cilium demo contour-gateway-api contour-gateway-demo-app

default:

kind:
	kind create cluster --config kind-proxyless.yaml
#	kind create cluster --config kind.yaml

clean:
	kind delete cluster --name proxyless

gateway-api:
	kubectl --context kind-proxyless apply -k gateway-api

cilium:
	helm repo add cilium https://helm.cilium.io/
	helm upgrade --install --kube-context kind-proxyless cilium cilium/cilium --version 1.13.2 --namespace kube-system -f cilium-proxyless.values.yaml
#	helm upgrade --install --kube-context kind-proxyless cilium cilium/cilium --version 1.13.2 --namespace kube-system -f cilium.values.yaml

cilium-gateway-api:
	kubectl --context kind-proxyless apply -k gateway-api-cilium

contour:
	helm upgrade --install --kube-context kind-proxyless contour oci://registry-1.docker.io/bitnamicharts/contour --namespace projectcontour --create-namespace -f contour.values.yaml

contour-gateway-api:
	kubectl --context kind-proxyless apply -k contour-gateway-api

contour-gateway-demo-app:
	kubectl --context kind-proxyless apply -k contour-gateway-demo-app

contour-httpproxy-demo-app:
	kubectl --context kind-proxyless apply -k contour-httpproxy-demo-app

apisix:
	helm repo add apisix https://charts.apiseven.com
	helm install apisix apisix/apisix --create-namespace  --namespace apisix -f apisix.values.yaml
	helm install apisix-ingress-controller apisix/apisix-ingress-controller --namespace apisix

apisix-bitnami:
	helm upgrade --install --kube-context kind-proxyless apisix oci://registry-1.docker.io/bitnamicharts/apisix --namespace apisix --create-namespace -f apisix.values.yaml

# linkerd really dislikes helm, so get yourself linkerd's cli `curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh`
linkerd:
	linkerd --context kind-proxyless check --pre
	linkerd --context kind-proxyless install --crds | kubectl apply -f -
	linkerd --context kind-proxyless install | kubectl apply -f -
	linkerd --context kind-proxyless check
	linkerd --context kind-proxyless viz install | kubectl apply -f -
	linkerd --context kind-proxyless viz check

linkerd-mesh-demo:
	kubectl --context kind-proxyless get -n emojivoto deploy -o yaml | linkerd inject - | kubectl --context kind-proxyless apply -f -

istio:
	helm repo add istio https://istio-release.storage.googleapis.com/charts
	helm --kube-context kind-proxyless upgrade --install --create-namespace istio-base istio/base -n istio-system
	helm --kube-context kind-proxyless upgrade --install istiod istio/istiod -n istio-system --wait

istio-gateway:
	helm --kube-context kind-proxyless upgrade --install --create-namespace istio-ingress istio/gateway -n istio-ingress --wait

demo:
	kubectl --context kind-proxyless apply -k demo-app
