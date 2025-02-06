CTX := "kind-kind"

default:
    @just --list

kind:
	kind create cluster --config=kind.yaml

[confirm]
clean:
	kind delete cluster

prometheus:
    kustomize build --enable-helm kube-prometheus-stack-crds | kubectl apply --server-side --context {{CTX}} -f -
    sleep 5
    kustomize build --enable-helm kube-prometheus-stack | kubectl apply --server-side --context {{CTX}} -f -

[private]
cilium:
	kustomize build --enable-helm cilium | kubectl apply --server-side --context {{CTX}} -f -

nginx:
    kustomize build --enable-helm nginx | kubectl apply --server-side --context {{CTX}} -f -

demo:
	kubectl --context {{CTX}} apply --server-side -k demo-app
