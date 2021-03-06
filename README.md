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
Welcome to Barge 2.13.0, Docker version 18.06.2-ce, build 6d37f41
[bargee@master ~]$ kubectl get nodes
NAME      STATUS   ROLES    AGE   VERSION
master    Ready    master   50s   v1.15.0
node-01   Ready    <none>   20s   v1.15.0
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
sample-pod   1/1     Running   0          11s
[bargee@master ~]$ kubectl get pods -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP           NODE      NOMINATED NODE   READINESS GATES
sample-pod   1/1     Running   0          23s   10.244.1.2   node-01   <none>           <none>
[bargee@master ~]$ kubectl logs sample-pod
[bargee@master ~]$ kubectl exec -it sample-pod bash
root@sample-pod:/# ls
bin  boot  dev	etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  srv  sys  tmp  usr  var
root@sample-pod:/# exit
exit
[bargee@master ~]$ kubectl port-forward sample-pod 8888:80 >/dev/null 2>&1 &
[1] 4600
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
[bargee@master ~]$ kill 4600
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
Welcome to Barge 2.13.0, Docker version 17.03.2-ce, build f5ec1e2
[bargee@master ~]$ kubectl get nodes
NAME      STATUS   ROLES    AGE     VERSION
master    Ready    master   4m41s   v1.15.0
node-01   Ready    <none>   3m57s   v1.15.0
node-02   Ready    <none>   21s     v1.15.0
```
