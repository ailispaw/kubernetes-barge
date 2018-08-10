# Istio

## Installation

https://istio.io/docs/setup/kubernetes/quick-start/

### Download the Istio release

```
[bargee@master ~]$ wget https://github.com/istio/istio/releases/download/1.0.0/istio-1.0.0-linux.tar.gz
[bargee@master ~]$ tar zxvf istio-1.0.0-linux.tar.gz
[bargee@master ~]$ cd istio-1.0.0
[bargee@master istio-1.0.0]$ export PATH=${PWD}/bin:${PATH}
```

### Install Istio’s Custom Resource Definitions

```
[bargee@master istio-1.0.0]$ kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
```

### Option 2: Install Istio with default mutual TLS authentication

```
[bargee@master istio-1.0.0]$ kubectl apply -f install/kubernetes/istio-demo-auth.yaml
[bargee@master istio-1.0.0]$ kubectl get services --namespace istio-system
[bargee@master istio-1.0.0]$ kubectl get pods --namespace istio-system
```

### Use NodePort for no external load balancer environment

```
[bargee@master istio-1.0.0]$ kubectl edit service -n istio-system istio-ingressgateway
# Edit `LoadBalancer` -> `NodePort`

[bargee@master istio-1.0.0]$ kubectl edit service -n istio-system istio-egressgateway
# Edit `ClusterIP` -> `NodePort`

[bargee@master istio-1.0.0]$ kubectl edit deployment -n istio-system istio-pilot
# Edit `memory: 2Gi` -> `memory: 512Mi`
```

## Deploy an application

https://istio.io/docs/examples/bookinfo/#if-you-are-running-on-kubernetes

### Enable the Istio-Sidecar-injector
```
[bargee@master istio-1.0.0]$ kubectl label namespace default istio-injection=enabled
[bargee@master istio-1.0.0]$ kubectl get namespaces -L istio-injection
```

### Deploy a sample application

```
[bargee@master istio-1.0.0]$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
[bargee@master istio-1.0.0]$ kubectl get services
[bargee@master istio-1.0.0]$ kubectl get pods
```

### Apply an Istio Gateway

```
[bargee@master istio-1.0.0]$ kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
[bargee@master istio-1.0.0]$ kubectl get gateway
[bargee@master istio-1.0.0]$ kubectl get virtualservice
```

### Use NodePort for no external load balancer environment

```
[bargee@master istio-1.0.0]$ kubectl edit service productpage
# Edit `ClusterIP` -> `NodePort`
```

### Disable Mutual TLS for productpage

```
[bargee@master istio-1.0.0]$ kubectl apply -f /vagrant/docs/productpage-ports-mtls-disabled.yaml
```
