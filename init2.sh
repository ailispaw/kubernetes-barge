
# MUST disable swap in order for the kubelet to work properly.
swapoff -a

# Make data persistent
for i in lib/cni lib/dockershim lib/etcd lib/kubelet log/containers log/pods ; do
  rm -f "/var/$i"
  mkdir -p "/mnt/data/var/$i"
  ln -s "/mnt/data/var/$i" "/var/$i"
done

# kubelet needs find instead of busybox find.
pkg install findutils
pkg install iproute2
pkg install socat
pkg install nsenter
pkg install schedutils
