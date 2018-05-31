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
Welcome to Barge 2.8.2, Docker version 17.03.2-ce, build f5ec1e2
[bargee@master ~]$ kubectl get nodes
NAME      STATUS    ROLES     AGE       VERSION
master    Ready     master    2m        v1.10.3
node-01   Ready     <none>    31s       v1.10.3
[bargee@master ~]$ kubectl cluster-info
Kubernetes master is running at https://192.168.65.100:6443
KubeDNS is running at https://192.168.65.100:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
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
Welcome to Barge 2.8.2, Docker version 17.03.2-ce, build f5ec1e2
[bargee@master ~]$ kubectl get nodes
NAME      STATUS    ROLES     AGE       VERSION
master    Ready     master    5m        v1.10.3
node-01   Ready     <none>    3m        v1.10.3
node-02   Ready     <none>    31s       v1.10.3
```
