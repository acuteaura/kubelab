.PHONY: apisix default kind kind-down cilium contour gateway-api gateway-api-cilium demo contour-gateway-api contour-gateway-demo-app

default:

kind:
	kind create cluster --config kind-proxyless.yaml
#	kind create cluster --config kind.yaml

clean:
	kind delete cluster --name proxyless

gateway-api:
	kubectl --context kind-proxyless apply -k gateway-api

prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus --create-namespace --wait

cilium:
	kustomize build --enable-helm cilium | kubectl apply --context kind-proxyless -f -

cilium-gateway-api:
	kubectl --context kind-proxyless apply -k gateway-api-cilium

contour:
	helm upgrade --install --kube-context kind-proxyless contour oci://registry-1.docker.io/bitnamicharts/contour --version 12.0.1 --namespace projectcontour --create-namespace -f contour.values.yaml --wait

contour-gateway-api:
	kubectl --context kind-proxyless apply -k contour-gateway-api

contour-gateway-demo-app:
	kubectl --context kind-proxyless apply -k contour-gateway-demo-app

contour-httpproxy-demo-app:
	kubectl --context kind-proxyless apply -k contour-httpproxy-demo-app

apisix:
	kustomize build --enable-helm apisix | kubectl apply --context kind-proxyless -f -

# do not use this one, there's the official above
apisix-bitnami:
	helm upgrade --install --kube-context kind-proxyless apisix oci://registry-1.docker.io/bitnamicharts/apisix --namespace apisix --create-namespace -f apisix.values.yaml --wait

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
