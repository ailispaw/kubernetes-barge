# Knative

## Installation

https://github.com/knative/docs/blob/master/install/Knative-with-Minikube.md

### Download the Istio release

```
[bargee@master ~]$ wget https://github.com/istio/istio/releases/download/1.0.0/istio-1.0.0-linux.tar.gz
[bargee@master ~]$ tar zxvf istio-1.0.0-linux.tar.gz
```

### Install Istio’s Custom Resource Definitions

```
[bargee@master ~]$ kubectl apply -f ./istio-1.0.0/install/kubernetes/helm/istio/templates/crds.yaml
```

### Install Istio for Knative

```
[bargee@master ~]$ wget https://raw.githubusercontent.com/knative/serving/master/third_party/istio-1.0.0/istio.yaml
[bargee@master ~]$ sed 's/LoadBalancer/NodePort/' -i istio.yaml
[bargee@master ~]$ sed 's/memory: 2048Mi/memory: 512Mi/' -i istio.yaml
[bargee@master ~]$ kubectl apply -f istio.yaml
[bargee@master ~]$ kubectl get services --namespace istio-system
[bargee@master ~]$ kubectl get pods --namespace istio-system
```

### Enable the Istio-Sidecar-injector

```
[bargee@master ~]$ kubectl label namespace default istio-injection=enabled
[bargee@master ~]$ kubectl get namespaces -L istio-injection
NAME           STATUS    AGE       ISTIO-INJECTION
default        Active    5m        enabled
istio-system   Active    3m        disabled
kube-public    Active    5m
kube-system    Active    5m
```

### Install Knative Serving

```
[bargee@master ~]$ wget https://github.com/knative/serving/releases/download/v0.1.1/release-lite.yaml
[bargee@master ~]$ sed 's/LoadBalancer/NodePort/' -i release-lite.yaml
[bargee@master ~]$ kubectl apply -f release-lite.yaml
[bargee@master ~]$ kubectl get services --namespace knative-serving
[bargee@master ~]$ kubectl get pods --namespace knative-serving
[bargee@master ~]$ kubectl get pods --all-namespaces
```

## Deploy an application

https://github.com/knative/docs/blob/master/install/getting-started-knative-app.md

```
[bargee@master ~]$ kubectl apply -f service.yaml
[bargee@master ~]$ kubectl get services
[bargee@master ~]$ kubectl get pods
[bargee@master ~]$ kubectl get services.serving.knative.dev helloworld-go  -o=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
NAME            DOMAIN
helloworld-go   helloworld-go.default.example.com
[bargee@master ~]$ kubectl get svc knative-ingressgateway --namespace istio-system
NAME                     TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                                      AGE
knative-ingressgateway   NodePort   10.108.160.29   <none>        80:32380/TCP,443:32390/TCP,32400:32400/TCP   12m
[bargee@master ~]$ wget -qO - --header="Host: helloworld-go.default.example.com" http://192.168.65.100:32380
Hello World: Go Sample v1!
```
