#!/usr/bin/env bash
# docker install
echo "======== are you sure want to install docker ? [yes/no] ========"
read -r confirm
if [ "yes" = "${confirm}" ]; then
  echo "======== installing docker ========"
  echo "======== uninstall old docker ========"
  sudo yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine
  if [ $? -eq 0 ]; then
    echo "======== install docker ========"
    sudo yum -y upgrade
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    sudo yum install docker-ce-19.03.11 docker-ce-cli-19.03.11 containerd.io -y
    if [ $? -eq 0 ]; then
      echo "======== docker install successfully ========"
      echo "======== config registry-mirrors ========"
      mkdir -p /etc/docker/
      cat > /etc/docker/daemon.json <<EOF
        {"registry-mirrors": ["https://xthau744.mirror.aliyuncs.com"],"exec-opts": ["native.cgroupdriver=systemd"]}
EOF
      if [ $? -eq 0 ]; then
        echo "======== start docker ========"
        sudo systemctl daemon-reload && systemctl enable docker && systemctl start docker
        if [ $? -eq 0 ]; then
          echo "======== docker install && start successfully ========"
        else
          echo "======== docker install successfully  start fail ========"
        fi
      else
        echo "======== config registry-mirrors fail ========"
      fi
    else
      echo "========  config registry-mirrors successfully  ========"
    fi
  else
    echo "======== uninstall old docker fail ========"
    exit
  fi
elif [ "no" = "${confirm}" ]; then
  exit
else
  echo "======== not support this operation ========"
fi