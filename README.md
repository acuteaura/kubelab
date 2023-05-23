## Quickstart

`make kind gateway-api cilium contour contour-gateway-api demo contour-gateway-demo-app`

Connect to demo app: [emojivoto.local.gd](http://emojivoto.local.gd)

Connect to hubble: `cilium ui hubble`

## Pending refactors

* Use CLIs over Helm for Cilium; Helm charts support unknown

## Targets

### kind

Install kind, requirement for everything else

### clean

Tear everything down

### gateway-api

Required. Installs latest gateway-api CRDs

### cilium

Required. Install Cilium, cluster has no CNI without this!

### cilium-gateway-api

Install Cilium Gateway. Gatewayclass is included in `cilium`. Mutually exclusive with `contour-gateway-api`, since they use the same `Gateway` object.. **Currently broken due to backing service not being configurable, will result in forever pending LoadBalancer**. [Issue tracking progress on this](https://github.com/cilium/cilium/issues/21923).

### linkerd

Install linkerd. Requires linkerd CLI because the developers hate Helm or something.

### linkerd-mesh-demo

Injects linkerd into `emojivoto`.

### istio



### contour

Install Contour. Gateway API support is enabled.

**Yes, this installs from Bitnami, who are a first-party vendor in this specific case - Contour is donated by VMWare and Bitnami is a VMWare company**

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

* Ensure cgroupsv2 is actually available: `mount | grep cgroupv2`
* Create / Edit `/etc/docker/daemon.json` to contain the following:
  
  ```json
  {
    "default-cgroupns-mode": "private",
    "exec-opts": ["native.cgroupdriver=cgroupfs"]
  }
  ```
* Colima can't do this, see [issue](https://github.com/abiosoft/colima/issues/720)