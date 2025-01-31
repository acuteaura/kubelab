CTX := "kind-proxyless"

default:
    @just --list

kind:
	kind create cluster --config kind-proxyless.yaml

[confirm]
clean:
	kind delete cluster --name proxyless

prometheus:
    kustomize build --enable-helm prometheus | kubectl apply --server-side --context {{CTX}} -f -

cilium:
	kustomize build --enable-helm cilium | kubectl apply --server-side --context {{CTX}} -f -

nginx:
    kustomize build --enable-helm nginx | kubectl apply --server-side --context {{CTX}} -f -

demo:
	kubectl --context --server-side {{CTX}} apply -k demo-app
