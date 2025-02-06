CTX := "kind-kind"
FAKETAG := choose('32', HEX)

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

miniauth:
    #!/usr/bin/env bash
    set -eou pipefail
    cd miniauth; docker build -f Containerfile -t local/miniauth .; cd ..
    export IMAGE_ID=$(docker inspect --format='{{{{index .Id}}' local/miniauth)
    export TAG=$(echo $IMAGE_ID | cut -d: -f2)
    export IMAGE=local/miniauth:$TAG
    docker tag $IMAGE_ID $IMAGE
    kind load docker-image $IMAGE
    yq -i '.spec.template.spec.containers[0].image = strenv(IMAGE)' miniauth-deploy/deployment.yaml
    kubectl --context {{CTX}} apply --server-side -k miniauth-deploy

minidefaultbackend:
    #!/usr/bin/env bash
    set -eou pipefail
    cd minidefaultbackend; docker build -f Containerfile -t local/minidefaultbackend .; cd ..
    export IMAGE_ID=$(docker inspect --format='{{{{index .Id}}' local/minidefaultbackend)
    export TAG=$(echo $IMAGE_ID | cut -d: -f2)
    export IMAGE=local/minidefaultbackend:$TAG
    docker tag $IMAGE_ID $IMAGE
    kind load docker-image $IMAGE
    yq -i '.defaultBackend.image.tag = strenv(TAG)' nginx/values.yaml
    just nginx
