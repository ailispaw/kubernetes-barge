
# MUST disable swap in order for the kubelet to work properly.
swapoff -a

# Make data persistent
for i in lib/cni lib/dockershim lib/etcd lib/kubelet log/containers log/pods ; do
  rm -f "/var/$i"
  mkdir -p "/mnt/data/var/$i"
  ln -s "/mnt/data/var/$i" "/var/$i"
done
