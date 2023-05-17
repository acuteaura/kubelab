## Targets

### kind-up

Install kind, requirement for everything else

### kind-down

Tear everything down

### gateway-api-up

Required. Installs latest gateway-api CRDs

### cilium-up

Required. Install Cilium, cluster has no CNI without this!

### cilium-gateway-api

Install Cilium Gateway. Gatewayclass is included in `cilium-up`. Mutually exclusive with `contour-gateway-api`, since they use the same `Gateway` object.. **Currently broken due to backing service not being configurable, will result in forever pending LoadBalancer**. [Issue tracking progress on this](https://github.com/cilium/cilium/issues/21923).

### linkerd-up

Install linkerd. Requires linkerd CLI because the developers hate Helm or something.

### linkerd-mesh-demo

Injects linkerd into `emojivoto`.

### istio-up



### contour-up

Install Contour. Gateway API support is enabled.

### contour-gateway-api

Install Contour `GatewayClass` and `Gateway`. Mutually exclusive with `cilium-gateway-api`, since they use the same `Gateway` object.

### contour-gateway-demo-app

Makes `demo-app` available at [emojivoto.local.gd](https://emojivoto.local.gd).

### contour-gateway-hubble

Makes Hubble UI (Cilium Mesh Dashboard) available at [hubble.local.gd](https://hubble.local.gd). Broken due to gRPC + h2c shenanigans. [Issue](https://github.com/cilium/hubble-ui/issues/452). Use Cilium UI's `cilium hubble ui` instead, or simply port-forward the service.

### contour-httpproxy-demo-app

Setup [emojivoto.local.gd](https://emojivoto.local.gd), but with Contour native CRD instead of Gateway API. Don't have both applied.

## Other stuff

### checking if cilium is okay

* install cilium CLI
* `cilium status`

### check cilium hubble

* install cilium CLI
* `cilium hubble ui`

# I can't read anything on localhost:80/localhost:443

Your OS or Dockerd is not using cgroupsv2.

* Set the following kernel args:
  * `systemd.unified_cgroup_hierarchy=1`
  * `cgroup_no_v1="all"`
  * [Guide for Fedora](https://fedoramagazine.org/setting-kernel-command-line-arguments-with-fedora-30/)
* Reboot. See if Docker starts properly.
  * If it does not, add `--default-cgroupns-mode=private` to dockerd arguments (via `systemctl edit --full docker.service`)
  * You can also relocate your cgroupfsv2 to a place Docker expects, add this to fstab:
    ```
    cgroup2 /sys/fs/cgroup cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate 0 0
    ```
