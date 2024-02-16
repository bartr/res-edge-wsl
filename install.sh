#!/bin/bash

echo "$SUDO_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$SUDO_USER

apt-get update
apt-get install -y curl git wget nano zsh

apt-get install -y curl git wget nano zsh
apt-get install -y jq zip unzip httpie dnsutils
apt-get install -y apt-utils dialog apt-transport-https ca-certificates curl software-properties-common
apt-get install -y apt-transport-https ca-certificates curl software-properties-common libssl-dev libffi-dev python2-dev build-essential cifs-utils git wget nano lsb-release jq gnupg-agent
apt-get install -y dotnet-sdk-7.0 golang

chsh $SUDO_USER -s /bin/zsh

# create / add to groups
groupadd docker
usermod -aG sudo ${ME}
usermod -aG admin ${ME}
usermod -aG docker ${ME}
gpasswd -a ${ME} sudo

# add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt update
apt-get install -y docker-ce docker-ce-cli containerd.io

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.4.6 bash

# install flux
curl -s https://fluxcd.io/install.sh | bash

tag=$(curl -s https://api.github.com/repos/cse-labs/res-edge-labs/releases/latest | grep tag_name | cut -d '"' -f4)

# install kic
wget -O kic.tar.gz "https://github.com/cse-labs/res-edge-labs/releases/download/$tag/kic-$tag-linux-amd64.tar.gz"
tar -xvzf kic.tar.gz -C /home/$ME/bin
rm kic.tar.gz

# install ds
wget -O ds.tar.gz "https://github.com/cse-labs/res-edge-labs/releases/download/$tag/ds-$tag-linux-amd64.tar.gz"
tar -xvzf ds.tar.gz -C /home/$ME/bin
rm ds.tar.gz

VERSION=$(curl -i https://github.com/derailed/k9s/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//')
wget https://github.com/derailed/k9s/releases/download/$VERSION/k9s_Linux_amd64.tar.gz
tar -zxvf k9s_Linux_amd64.tar.gz -C /usr/local/bin
rm -f k9s_Linux_x86_64.tar.gz

# install jp (jmespath)
VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//')
wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp
chmod +x /usr/local/bin/jp

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/msprod.list
apt-get update
ACCEPT_EULA=y apt-get install -y mssql-tools unixodbc-dev

cd /usr/local/bin
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
cd $OLD_PWD

#apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
#apt-add-repository https://cli.github.com/packages
#apt-get update
#apt-get install -y gh

# change ownership of home directory
chown -R ${ME}:${ME} /home/${ME}

# update wsl.conf
printf "\n[user]\ndefault=$SUDO_USER\n" >> /etc/wsl.conf
