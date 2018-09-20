# Istio

## Installation

https://istio.io/docs/setup/kubernetes/quick-start/

### Download the Istio release

```
[bargee@master ~]$ wget https://github.com/istio/istio/releases/download/1.0.2/istio-1.0.2-linux.tar.gz
[bargee@master ~]$ tar zxvf istio-1.0.2-linux.tar.gz
[bargee@master ~]$ mv istio-1.0.2 istio
[bargee@master ~]$ cd istio
[bargee@master istio]$ export PATH=${PWD}/bin:${PATH}
```

### Install Istio’s Custom Resource Definitions

```
[bargee@master istio]$ kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
```

### Option 2: Install Istio with default mutual TLS authentication

```
[bargee@master istio]$ kubectl apply -f install/kubernetes/istio-demo-auth.yaml
[bargee@master istio]$ kubectl get services --namespace istio-system
[bargee@master istio]$ kubectl get pods --namespace istio-system
```

### Use NodePort for no external load balancer environment

```
[bargee@master istio]$ kubectl edit service -n istio-system istio-ingressgateway
# Edit `LoadBalancer` -> `NodePort`
[bargee@master istio]$ kubectl get services --namespace istio-system
```

## Deploy an application

https://istio.io/docs/examples/bookinfo/#if-you-are-running-on-kubernetes

### Enable the Istio-Sidecar-injector
```
[bargee@master istio]$ kubectl label namespace default istio-injection=enabled
[bargee@master istio]$ kubectl get namespaces -L istio-injection
```

### Deploy a sample application

```
[bargee@master istio]$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
[bargee@master istio]$ kubectl get services
[bargee@master istio]$ kubectl get pods
```

### Apply an Istio Gateway

```
[bargee@master istio]$ kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
[bargee@master istio]$ kubectl get gateway
[bargee@master istio]$ kubectl get virtualservice
```

### Use NodePort for no external load balancer environment

```
[bargee@master istio]$ kubectl edit service productpage
# Edit `ClusterIP` -> `NodePort`
[bargee@master istio]$ kubectl get services
```

### Disable Mutual TLS for productpage

```
[bargee@master istio]$ kubectl apply -f /vagrant/docs/productpage-ports-mtls-disabled.yaml
```
