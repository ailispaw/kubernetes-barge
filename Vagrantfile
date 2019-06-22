# A dummy plugin for Barge to set hostname and network correctly at the very first `vagrant up`
module VagrantPlugins
  module GuestLinux
    class Plugin < Vagrant.plugin("2")
      guest_capability("linux", "change_host_name") { Cap::ChangeHostName }
      guest_capability("linux", "configure_networks") { Cap::ConfigureNetworks }
    end
  end
end

NUM_OF_NODES = 2
BASE_IP_ADDR = "192.168.65"

DOCKER_VERSION = "v18.06.2-ce"
CNI_VERSION    = "v0.7.5"
CRICTL_VERSION = "v1.14.0"
K8S_VERSION    = "v1.15.0"

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

      # https://kubernetes.io/docs/setup/independent/install-kubeadm/

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

      if [ ! -f "/vagrant/dl/crictl-#{CRICTL_VERSION}-linux-amd64.tar.gz" ]; then
        wget -nv https://github.com/kubernetes-incubator/cri-tools/releases/download/#{CRICTL_VERSION}/crictl-#{CRICTL_VERSION}-linux-amd64.tar.gz -O /vagrant/dl/crictl-#{CRICTL_VERSION}-linux-amd64.tar.gz
      fi

      rm -f /opt/bin/crictl
      tar -xzf /vagrant/dl/crictl-#{CRICTL_VERSION}-linux-amd64.tar.gz -C /opt/bin

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
      pkg build conntrack-tools
      mkdir -p /vagrant/pkg/
      cp /opt/pkg/${VERSION}/barge-pkg-*-${VERSION}.tar.gz /vagrant/pkg/

      bash /vagrant/init2.sh
      cat /vagrant/init2.sh >> /etc/init.d/init.sh
    EOT
  end

  NODE_HOSTNAME = Array.new(NUM_OF_NODES+1)
  NODE_IP_ADDR  = Array.new(NUM_OF_NODES+1)

  NODE_HOSTNAME[0] = "master"
  NODE_IP_ADDR[0]  = "#{BASE_IP_ADDR}.100"

  config.vm.define NODE_HOSTNAME[0] do |node|
    node.vm.hostname = NODE_HOSTNAME[0]

    node.vm.provider :virtualbox do |vb|
      vb.cpus = 2
    end

    node.vm.network :private_network, ip: NODE_IP_ADDR[0]

    node.vm.provision :shell do |sh|
      sh.inline = <<-EOT
        sed 's/127\\.0\\.1\\.1.*#{NODE_HOSTNAME[0]}.*/#{NODE_IP_ADDR[0]} #{NODE_HOSTNAME[0]}/' \
          -i /etc/hosts

        setsid kubeadm init --pod-network-cidr=10.244.0.0/16 \
          --apiserver-advertise-address #{NODE_IP_ADDR[0]} >/vagrant/kubeadm.log 2>&1 &

        echo "Waiting for kubeadm to generate the configuration file for kubelet"
        while [ ! -f /etc/kubernetes/kubelet.conf ]; do
          sleep 1
        done

        echo 'KUBELET_EXTRA_ARGS="--node-ip #{NODE_IP_ADDR[0]}"' >> /etc/kubernetes/kubeadm.conf
        /etc/init.d/S99kubelet start
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

        kubectl apply -f /vagrant/kube-flannel.yml

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
          sed 's/127\\.0\\.1\\.1.*#{NODE_HOSTNAME[i]}.*/#{NODE_IP_ADDR[i]} #{NODE_HOSTNAME[i]}/' \
            -i /etc/hosts

          KUBEADM_JOIN="$(sed -n '/^kubeadm join/,+1p' /vagrant/kubeadm.log)"
          echo "${KUBEADM_JOIN}"
          setsid $(echo ${KUBEADM_JOIN} | sed 's/\\\\ //') >/var/log/kubeadm.log 2>&1 &

          echo "Waiting for kubeadm to get the certificate for kubelet"
          while [ ! -f /etc/kubernetes/pki/ca.crt ]; do
            sleep 1
          done

          echo 'KUBELET_EXTRA_ARGS="--node-ip #{NODE_IP_ADDR[i]}"' >> /etc/kubernetes/kubeadm.conf
          /etc/init.d/S99kubelet start
        EOT
      end
    end
  end
end
