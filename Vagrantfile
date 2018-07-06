# A dummy plugin for Barge to set hostname and network correctly at the very first `vagrant up`
module VagrantPlugins
  module GuestLinux
    class Plugin < Vagrant.plugin("2")
      guest_capability("linux", "change_host_name") { Cap::ChangeHostName }
      guest_capability("linux", "configure_networks") { Cap::ConfigureNetworks }
    end
  end
end

NUM_OF_NODES = 1
BASE_IP_ADDR = "192.168.65"

DOCKER_VERSION = "v17.03.2-ce"
CNI_VERSION    = "v0.7.1"
K8S_VERSION    = "v1.11.0"
OVSCNI_VERSION = "1.0.0-rc1"

Vagrant.configure(2) do |config|
  config.vm.box = "ailispaw/barge"
  config.vm.box_version = ">= 2.9.0"

  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  end

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provision :shell do |sh|
    sh.inline = <<-EOT
      set -e

      /etc/init.d/docker restart #{DOCKER_VERSION}

      # https://kubernetes.io/docs/tasks/tools/install-kubeadm

      mkdir -p /vagrant/dl

      if [ ! -f "/vagrant/dl/kubeadm-#{K8S_VERSION}" ]; then
        wget -nv https://storage.googleapis.com/kubernetes-release/release/#{K8S_VERSION}/bin/linux/amd64/kubeadm -O /vagrant/dl/kubeadm-#{K8S_VERSION}
        wget -nv https://storage.googleapis.com/kubernetes-release/release/#{K8S_VERSION}/bin/linux/amd64/kubelet -O /vagrant/dl/kubelet-#{K8S_VERSION}
        wget -nv https://storage.googleapis.com/kubernetes-release/release/#{K8S_VERSION}/bin/linux/amd64/kubectl -O /vagrant/dl/kubectl-#{K8S_VERSION}
      fi

      cp -f /vagrant/dl/kubeadm-#{K8S_VERSION} /opt/bin/kubeadm
      cp -f /vagrant/dl/kubelet-#{K8S_VERSION} /opt/bin/kubelet
      cp -f /vagrant/dl/kubectl-#{K8S_VERSION} /opt/bin/kubectl
      chmod +x /opt/bin/{kubeadm,kubelet,kubectl}

      if [ ! -f "/vagrant/dl/cni-plugins-amd64-#{CNI_VERSION}.tgz" ]; then
        wget -nv https://github.com/containernetworking/plugins/releases/download/#{CNI_VERSION}/cni-plugins-amd64-#{CNI_VERSION}.tgz -O /vagrant/dl/cni-plugins-amd64-#{CNI_VERSION}.tgz
      fi

      rm -rf /opt/cni/bin
      mkdir -p /opt/cni/bin
      tar -xzf /vagrant/dl/cni-plugins-amd64-#{CNI_VERSION}.tgz -C /opt/cni/bin

      if [ ! -f "/vagrant/dl/ovs-#{OVSCNI_VERSION}" ]; then
        wget -nv https://github.com/ailispaw/ovs-cni/releases/download/#{OVSCNI_VERSION}/ovs \
          -O /vagrant/dl/ovs-#{OVSCNI_VERSION}
        wget -nv https://github.com/ailispaw/ovs-cni/releases/download/#{OVSCNI_VERSION}/centralip \
          -O /vagrant/dl/centralip-#{OVSCNI_VERSION}
      fi

      cp -f /vagrant/dl/ovs-#{OVSCNI_VERSION}       /opt/cni/bin/ovs
      cp -f /vagrant/dl/centralip-#{OVSCNI_VERSION} /opt/cni/bin/centralip
      chmod +x /opt/cni/bin/{ovs,centralip}

      if [ ! -f "/vagrant/dl/crictl-#{K8S_VERSION}-linux-amd64.tar.gz" ]; then
        wget -nv https://github.com/kubernetes-incubator/cri-tools/releases/download/#{K8S_VERSION}/crictl-#{K8S_VERSION}-linux-amd64.tar.gz -O /vagrant/dl/crictl-#{K8S_VERSION}-linux-amd64.tar.gz
      fi

      rm -f /opt/bin/crictl
      tar -xzf /vagrant/dl/crictl-#{K8S_VERSION}-linux-amd64.tar.gz -C /opt/bin

      mkdir -p /etc/kubernetes
      cp /vagrant/kubeadm.conf /etc/kubernetes/
      cp /vagrant/S99kubelet /etc/init.d/

      source /etc/os-release
      mkdir -p /opt/pkg/${VERSION}/
      cp /vagrant/pkg/barge-pkg-*-${VERSION}.tar.gz /opt/pkg/${VERSION}/ || true
      pkg build findutils
      pkg build iproute2
      pkg build socat
      pkg build nsenter || (\
        pkg build util-linux -e BR2_PACKAGE_UTIL_LINUX_NSENTER=y && \
        cd /opt/pkg/${VERSION}/ && \
        mv barge-pkg-util-linux-${VERSION}.tar.gz barge-pkg-nsenter-${VERSION}.tar.gz)
      pkg build schedutils || (\
        pkg build util-linux -e BR2_PACKAGE_UTIL_LINUX_SCHEDUTILS=y && \
        cd /opt/pkg/${VERSION}/ && \
        mv barge-pkg-util-linux-${VERSION}.tar.gz barge-pkg-schedutils-${VERSION}.tar.gz)
      mkdir -p /vagrant/pkg/
      cp /opt/pkg/${VERSION}/barge-pkg-*-${VERSION}.tar.gz /vagrant/pkg/

      bash /vagrant/init2.sh
      cat /vagrant/init2.sh >> /etc/init.d/init.sh

      mkdir -p /etc/cni/net.d
      cp -f /vagrant/ovs-cni.conf /etc/cni/net.d/ovs-cni.conf

      # modprobe openvswitch
      docker run -d --net=host --privileged --name openvswitch \
        -v /lib/modules:/lib/modules:ro \
        -v /var/log/openvswitch:/var/log/openvswitch \
        -v /var/lib/openvswitch:/var/lib/openvswitch \
        -v /var/run/openvswitch:/var/run/openvswitch \
        -v /etc/openvswitch:/etc/openvswitch \
        ailispaw/openvswitch:2.8.1-alpine

      docker exec openvswitch ovs-vsctl add-br br0
    EOT
  end

  NODE_HOSTNAME = Array.new(NUM_OF_NODES+1)
  NODE_IP_ADDR  = Array.new(NUM_OF_NODES+1)

  NODE_HOSTNAME[0] = "master"
  NODE_IP_ADDR[0]  = "#{BASE_IP_ADDR}.100"

  config.vm.define NODE_HOSTNAME[0] do |node|
    node.vm.hostname = NODE_HOSTNAME[0]

    node.vm.network :private_network, ip: NODE_IP_ADDR[0]

    node.vm.provision :shell do |sh|
      sh.inline = <<-EOT
        set -e

        sed 's/127\\.0\\.1\\.1.*#{NODE_HOSTNAME[0]}.*/#{NODE_IP_ADDR[0]} #{NODE_HOSTNAME[0]}/' \
          -i /etc/hosts

        kubeadm config images pull

        kubeadm alpha phase preflight master || true

        # kubeadm alpha phase certs all --apiserver-advertise-address #{NODE_IP_ADDR[0]}
        kubeadm alpha phase certs ca
        kubeadm alpha phase certs apiserver --apiserver-advertise-address #{NODE_IP_ADDR[0]}
        kubeadm alpha phase certs apiserver-kubelet-client

        kubeadm alpha phase certs etcd-ca --config /vagrant/etcd-server.yml
        kubeadm alpha phase certs etcd-server --config /vagrant/etcd-server.yml
        kubeadm alpha phase certs etcd-peer --config /vagrant/etcd-server.yml
        kubeadm alpha phase certs etcd-healthcheck-client --config /vagrant/etcd-server.yml
        kubeadm alpha phase certs apiserver-etcd-client --config /vagrant/etcd-server.yml

        kubeadm alpha phase certs sa
        kubeadm alpha phase certs front-proxy-ca
        kubeadm alpha phase certs front-proxy-client

        kubeadm alpha phase kubeconfig all --apiserver-advertise-address #{NODE_IP_ADDR[0]}
        kubeadm alpha phase controlplane all --apiserver-advertise-address #{NODE_IP_ADDR[0]} \
          --pod-network-cidr=10.244.0.0/16
        kubeadm alpha phase etcd local

        sed 's/--advertise-client-urls=https:\\/\\/127\\.0\\.0\\.1:2379/--advertise-client-urls=https:\\/\\/192\\.168\\.65\\.100:2379/' \
          -i /etc/kubernetes/manifests/etcd.yaml
        sed 's/--listen-client-urls=https:\\/\\/127\\.0\\.0\\.1:2379/--listen-client-urls=https:\\/\\/0\\.0\\.0\\.0:2379/' \
          -i /etc/kubernetes/manifests/etcd.yaml

        echo 'KUBELET_EXTRA_ARGS="--node-ip #{NODE_IP_ADDR[0]}"' >> /etc/kubernetes/kubeadm.conf
        /etc/init.d/S99kubelet start

        kubeadm alpha phase mark-master

        # kubeadm alpha phase upload-config
        kubeadm config upload from-flags --apiserver-advertise-address #{NODE_IP_ADDR[0]} \
          --pod-network-cidr=10.244.0.0/16

        # kubeadm alpha phase kubelet
        kubeadm config view > /vagrant/kubeadm.yml
        kubeadm alpha phase kubelet write-env-file --config /vagrant/kubeadm.yml
        kubeadm alpha phase kubelet config write-to-disk --config /vagrant/kubeadm.yml
        kubeadm alpha phase kubelet config upload --config /vagrant/kubeadm.yml

        # kubeadm alpha phase patchnode
        kubectl --kubeconfig /etc/kubernetes/admin.conf annotate nodes master \
          kubeadm.alpha.kubernetes.io/cri-socket="/var/run/dockershim.sock"

        kubeadm alpha phase bootstrap-token all
        kubeadm alpha phase addon all --apiserver-advertise-address #{NODE_IP_ADDR[0]} \
          --pod-network-cidr=10.244.0.0/16

        kubeadm token create --print-join-command > /vagrant/join-command.sh

        mkdir -p /vagrant/etcd
        cp /etc/kubernetes/pki/etcd/healthcheck-client.crt /vagrant/etcd/healthcheck-client.crt
        cp /etc/kubernetes/pki/etcd/healthcheck-client.key /vagrant/etcd/healthcheck-client.key
        cp /etc/kubernetes/pki/etcd/ca.crt                 /vagrant/etcd/ca.crt
      EOT
    end

    node.vm.provision :shell do |sh|
      sh.privileged = false
      sh.inline = <<-EOT
        mkdir -p ${HOME}/.kube
        sudo cp -f /etc/kubernetes/admin.conf ${HOME}/.kube/config
        sudo chown $(id -u):$(id -g) ${HOME}/.kube/config

        echo "Waiting for the kube-apiserver"
        while ! kubectl api-versions 2>/dev/null | grep -q "rbac.authorization.k8s.io/v1beta1"; do
          sleep 1
        done

        kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null
      EOT
    end
  end

  (1..NUM_OF_NODES).each do |i|
    NODE_HOSTNAME[i] = "node-%02d" % i
    NODE_IP_ADDR[i]  = "#{BASE_IP_ADDR}.#{100+i}"

    config.vm.define NODE_HOSTNAME[i] do |node|
      node.vm.hostname = NODE_HOSTNAME[i]

      node.vm.network :private_network, ip: NODE_IP_ADDR[i]

      node.vm.provision :shell do |sh|
        sh.inline = <<-EOT
          mkdir -p /etc/kubernetes/pki/etcd
          cp /vagrant/etcd/healthcheck-client.crt /etc/kubernetes/pki/etcd/healthcheck-client.crt
          cp /vagrant/etcd/healthcheck-client.key /etc/kubernetes/pki/etcd/healthcheck-client.key
          cp /vagrant/etcd/ca.crt                 /etc/kubernetes/pki/etcd/ca.crt

          sed 's/127\\.0\\.1\\.1.*#{NODE_HOSTNAME[i]}.*/#{NODE_IP_ADDR[i]} #{NODE_HOSTNAME[i]}/' \
            -i /etc/hosts

          cat /vagrant/join-command.sh
          setsid sh /vagrant/join-command.sh >/var/log/kubeadm.log 2>&1 &

          echo "Waiting for kubeadm to get the certificate for kubelet"
          while [ ! -f /etc/kubernetes/pki/ca.crt ]; do
            sleep 1
          done

          sed 's/"192\\.168\\.65\\.#{100+i}"/"192\\.168\\.65\\.100"/g' \
            -i /etc/cni/net.d/ovs-cni.conf

          echo 'KUBELET_EXTRA_ARGS="--node-ip #{NODE_IP_ADDR[i]}"' >> /etc/kubernetes/kubeadm.conf
          /etc/init.d/S99kubelet start
        EOT
      end
    end
  end
end
