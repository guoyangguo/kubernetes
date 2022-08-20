#!/bin/bash
# install containerd

echo "******** containerd env init ********"

echo "::::::::: yum update ::::::::"
yum -y update

echo "::::::::: install wget ::::::::"
yum install wget -y

echo "::::::::: install containerd ::::::::"
rpm -qa |grep libseccomp
if [ $? !=0 ]; then
  echo "======== install libseccomp ========"
  wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libseccomp-2.3.1-4.el7.x86_64.rpm
  yum install libseccomp-2.3.1-4.el7.x86_64.rpm -y
  echo "======== install lib successed ========"
fi

echo "======== install containerd ========"
# wget https://github.com/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz
# 如果有限制，也可以替换成下面的 URL 加速下载
wget https://download.fastgit.org/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz
tar -C / -xzf cri-containerd-cni-1.5.5-linux-amd64.tar.gz
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
source ~/.bashrc 

echo ">>>>>>>> config containerd >>>>>>>>"
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
cat>/etc/systemd/system/containerd.service<< EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF
echo ">>>>>>>> enable containerd >>>>>>>>"
systemctl enable containerd --now
echo ">>>>>>>> contianerd version >>>>>>>>"
ctr version
if [ $? != 0 ]; then
  echo "======== install containerd failed ========"
  exit 1
fi
echo "======== install containerd successed ========"

echo "======== remove cri-containerd-cni-1.5.5-linux-amd64.tar.gz ======== "
rm -f cri-containerd-cni-1.5.5-linux-amd64.tar.gz

echo "======== install nerdctl ========"

# wget https://github.com/containerd/nerdctl/releases/download/v0.12.1/nerdctl-0.12.1-linux-amd64.tar.gz
# 如果有限制，也可以替换成下面的 URL 加速下载
wget https://download.fastgit.org/containerd/nerdctl/releases/download/v0.12.1/nerdctl-0.12.1-linux-amd64.tar.gz

mkdir -p /usr/local/containerd/bin/ && tar -zxvf nerdctl-0.12.1-linux-amd64.tar.gz nerdctl && mv nerdctl /usr/local/containerd/bin/
ln -s /usr/local/containerd/bin/nerdctl /usr/local/bin/nerdctl
nerdctl version
if [ $? != 0 ]; then
  echo "======== install nerdctl failed ========"
  exit 1
fi
echo "======== install nerdctl successed ========"
echo "======== remove nerdctl-0.12.1-linux-amd64.tar.gz ======== "
rm -f nerdctl-0.12.1-linux-amd64.tar.gz
echo "********  All done ********"
