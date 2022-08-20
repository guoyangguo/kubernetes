#!/bin/bash
# install k8s

echo "******** k8s env init ********"

echo "::::::::: yum update ::::::::"
yum -y update

echo "::::::::: install wget ::::::::"
yum install wget -y

echo "::::::::: set host ::::::::"

# ipaddress not 
cat>>/etc/hosts<< EOF
192.168.94.100 master1
#192.168.94.101 node1
192.168.94.102 node2
EOF

echo "::::::::: disable firewalld ::::::::" 
systemctl stop firewalld
systemctl disable firewalld

echo "::::::::: disable setlinux ::::::::" 
setenforce 0
cat>>/etc/selinux/config<< EOF
SELINUX=disabled
EOF
modprobe br_netfilter
for file in /etc/sysconfig/modules/*.modules ; do
[ -x $file ] && $file
done
cat>/etc/sysconfig/modules/br_netfilter.modules<< EOF
modprobe br_netfilter
EOF
chmod 755 /etc/sysconfig/modules/br_netfilter.modules

echo "::::::::: set k8s.conf ::::::::"
cat> /etc/sysctl.d/k8s.conf<< EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
# 下面的内核参数可以解决ipvs模式下长连接空闲超时的问题
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 10
net.ipv4.tcp_keepalive_time = 600
EOF

echo "::::::::: enable k8s.conf ::::::::"
sysctl -p /etc/sysctl.d/k8s.conf
if [ $? !=0 ]; then
  echo "::::::::: enable k8s.conf failed ::::::::"
  exit 1
fi
echo "::::::::: enable k8s.conf successed ::::::::"

echo "::::::::: set ipvs ::::::::"
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
if [ $? != 0 ]; then
  echo "::::::::: set ipvs failed ::::::::"
  exit 1
fi
echo "::::::::: set ipvs successed ::::::::"

echo "::::::::: install ipset and ipvsadm ::::::::"
yum install ipset -y
yum install ipvsadm -y

echo "::::::::: sync time ::::::::"
yum install chrony -y
systemctl enable chronyd
systemctl start chronyd
chronyc sources
if [ $? != 0 ]; then 
  echo "::::::::: sync time failed ::::::::"
  exit 1
fi

echo "::::::::: disable swap ::::::::"
swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab
cat>>/etc/sysctl.d/k8s.conf<<EOF
vm.swappiness=0
EOF

echo "******** k8s env init end ********"

# ++++++++ install containerd ++++++++
#sh crd_env.sh
# ++++++++ install containerd end ++++++++

# ++++++++ init k8s cluster ++++++++
echo "::::::::: set kubernetes.repo ::::::::" 
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
echo "::::::::: set kubernetes.repo end ::::::::" 

echo "::::::::: install  kubeadmin kubelet kubectl ::::::::" 
yum makecache fast
#yum install -y kubelet-1.22.2 kubeadm-1.22.2 kubectl-1.22.2 --disableexcludes=kubernetes
yum install -y kubelet-1.16.2 kubeadm-1.16.2 kubectl-1.16.2 --disableexcludes=kubernetes
kubeadm version
if [ $? != 0 ]; then
  echo ":::::::: install  kubeadmin kubelet kubectl failed ::::::::"
  exit 1
fi
echo ":::::::: install  kubeadmin kubelet kubectl successed ::::::::"
systemctl enable --now kubelet
echo ":::::::: generate kubeadm.yaml ::::::::"
kubeadm config print init-defaults --component-configs KubeletConfiguration > kubeadm.yaml
echo ":::::::: generate kubeadm.yaml succcessed ::::::::"
echo ":::::::: please manually initialize the cluster according to kubeadm.yaml ::::::::"

# ++++++++ init k8s cluster end ++++++++

