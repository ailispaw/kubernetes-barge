# Kubebuilder

https://book.kubebuilder.io/

## Installation

### Install go

```
[bargee@master ~]$ wget -nv https://storage.googleapis.com/golang/go1.10.4.linux-amd64.tar.gz
[bargee@master ~]$ sudo tar zxf go1.10.4.linux-amd64.tar.gz -C /opt
```

```
[bargee@master ~]$ cat <<EOF >> ~/.bash_profile
export GOROOT=/opt/go
export GOPATH=\${HOME}/go
export PATH=\${PATH}:\${GOROOT}/bin:\${GOPATH}/bin
EOF
```

### Install git and make

```
[bargee@master ~]$ sudo pkg install git
[bargee@master ~]$ git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
[bargee@master ~]$ sudo pkg install make
```

### Install dep, kustomize and kubebuilder

https://book.kubebuilder.io/quick_start.html

```
[bargee@master ~]$ mkdir -p ~/go/bin
[bargee@master ~]$ wget -nv https://raw.githubusercontent.com/golang/dep/master/install.sh
[bargee@master ~]$ chmod +x install.sh
[bargee@master ~]$ ./install.sh
```

```
[bargee@master ~]$ wget -nv https://github.com/kubernetes-sigs/kustomize/releases/download/v1.0.8/kustomize_1.0.8_linux_amd64
[bargee@master ~]$ chmod u+x kustomize_1.0.8_linux_amd64
[bargee@master ~]$ sudo mv kustomize_1.0.8_linux_amd64 /opt/bin/kustomize
```

```
[bargee@master ~]$ wget -nv https://github.com/kubernetes-sigs/kubebuilder/releases/download/v1.0.4/kubebuilder_1.0.4_linux_amd64.tar.gz
[bargee@master ~]$ tar zxvf kubebuilder_1.0.4_linux_amd64.tar.gz
[bargee@master ~]$ sudo mv kubebuilder_1.0.4_linux_amd64 /opt/kubebuilder
[bargee@master ~]$ sudo mkdir -p /usr/local
[bargee@master ~]$ sudo ln -s /opt/kubebuilder /usr/local/kubebuilder
[bargee@master ~]$ cat <<EOF >> ~/.bash_profile
export PATH=\${PATH}:/opt/kubebuilder/bin
EOF
```

## Create an extension

https://book.kubebuilder.io/basics/simple_resource.html

```
[bargee@master ~]$ mkdir -p ~/go/src/github.com/ailispaw/kube-ext-tutorial
[bargee@master ~]$ cd ~/go/src/github.com/ailispaw/kube-ext-tutorial
[bargee@master kube-ext-tutorial]$ kubebuilder init --domain k9s.paw.zone --license apache2 --owner "A.I.<ailis@paw.zone>"
[bargee@master kube-ext-tutorial]$ kubebuilder create api --group workloads --version v1beta1 --kind ContainerSet
```

## Test the extension

```
[bargee@master kube-ext-tutorial]$ make install
[bargee@master kube-ext-tutorial]$ make run
go generate ./pkg/... ./cmd/...
go fmt ./pkg/... ./cmd/...
go vet ./pkg/... ./cmd/...
go run ./cmd/manager/main.go
2018/09/20 20:12:32 Registering Components.
2018/09/20 20:12:32 Starting the Cmd.
```

```
[bargee@master kube-ext-tutorial]$ kubectl apply -f config/samples/workloads_v1beta1_containerset.yaml
containerset.workloads.k9s.paw.zone/containerset-sample created
[bargee@master kube-ext-tutorial]$ kubectl get containersets.workloads.k9s.paw.zone
NAME                  AGE
containerset-sample   15s
```

## Deploy the extension

```
[bargee@master kube-ext-tutorial]$ export IMG=ailispaw/kube-ext-tutorial:v1
[bargee@master kube-ext-tutorial]$ make docker-build
[bargee@master kube-ext-tutorial]$ docker login
[bargee@master kube-ext-tutorial]$ make docker-push
[bargee@master kube-ext-tutorial]$ make deploy
```
