## Targets

|-|-|
| target         | description                                                                                                                                                                |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| kind-up        | create kind cluster                                                                                                                                                        |
| kind-down      | remove kind cluster, essentially a full reset                                                                                                                              |
| cilium-up      | install cilium, required since no CNI or kube-proxy is deployed                                                                                                            |
| cilium-upgrade | refresh values for cilium install, combine with `kubectl -n kube-system rollout restart deployment/cilium-operator` and `kubectl -n kube-system rollout restart ds/cilium` |
| contour-up | install contour via helm |
| gateway-up | install gateway-api CRDs (latest) |
| demo-up | install emojivoto (linkerd mesh demo) |

# checking if cilium is okay

* install cilium CLI
* `cilium status`

# check cilium hubble

* install cilium CLI
* `cilium hubble ui`