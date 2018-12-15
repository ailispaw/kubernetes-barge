# Kubernetes Cluster on Barge with Vagrant

[Kubernetes](https://kubernetes.io/) is an open-source system for automating deployment, scaling, and management of containerized applications.

> It groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon 15 years of experience of running production workloads at Google, combined with best-of-breed ideas and practices from the community.

This repo creates a Kubernetes cluster on [Barge](https://github.com/bargees/barge-os) with [Vagrant](https://www.vagrantup.com/) locally and instantly.

## Requirements

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

## Boot up

```
$ vagrant up
```

That's it.

It will create one Master VM and one Node VM by default.

```
$ vagrant ssh master
Welcome to Barge 2.11.0, Docker version 17.03.2-ce, build f5ec1e2
[bargee@master ~]$ kubectl get nodes
NAME      STATUS   ROLES    AGE     VERSION
master    Ready    master   12m     v1.13.1
node-01   Ready    <none>   8m38s   v1.13.1
[bargee@master ~]$ kubectl cluster-info
Kubernetes master is running at https://192.168.65.100:6443
KubeDNS is running at https://192.168.65.100:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

## Create a Sample Pod

```
[bargee@master ~]$ kubectl create -f /vagrant/samples/sample-pod.yml
pod/sample-pod created
[bargee@master ~]$ kubectl get pods
NAME         READY   STATUS    RESTARTS   AGE
sample-pod   1/1     Running   0          45s
[bargee@master ~]$ kubectl get pods -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP           NODE      NOMINATED NODE   READINESS GATES
sample-pod   1/1     Running   0          62s   10.244.1.2   node-01   <none>           <none>
[bargee@master ~]$ kubectl logs sample-pod
[bargee@master ~]$ kubectl exec -it sample-pod bash
root@sample-pod:/# ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
root@sample-pod:/# exit
exit
[bargee@master ~]$ kubectl port-forward sample-pod 8888:80 >/dev/null 2>&1 &
[1] 7444
[bargee@master ~]$ wget -qO- http://localhost:8888
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
[bargee@master ~]$ kill 29425
[bargee@master ~]$ kubectl delete -f /vagrant/samples/sample-pod.yml
pod "sample-pod" deleted
[bargee@master ~]$ kubectl get pods
No resources found.
```

## Scale Up

You can add more Nodes to modify the following line in the `Vagrantfile`.

```ruby
NUM_OF_NODES = 2
```

and execute `vagrant up node-<n>` to boot up an additional node.

```
$ vagrant up node-02
```

```
$ vagrant ssh master
Welcome to Barge 2.11.0, Docker version 17.03.2-ce, build f5ec1e2
[bargee@master ~]$ kubectl get nodes
NAME      STATUS   ROLES    AGE   VERSION
master    Ready    master   19m   v1.13.1
node-01   Ready    <none>   14m   v1.13.1
node-02   Ready    <none>   52s   v1.13.1
```
