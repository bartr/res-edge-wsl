#!/bin/bash

update-alternatives --set iptables /usr/sbin/iptables-legacy

# no password for sudo
echo "$SUDO_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$SUDO_USER

# add lab-01 to hosts
echo "" >> /etc/hosts
echo -e "192.168.0.4\tlab-01" >> /etc/hosts

# create / add to groups
groupadd docker
usermod -aG sudo $SUDO_USER
usermod -aG admin $SUDO_USER
usermod -aG docker $SUDO_USER
gpasswd -a $SUDO_USER sudo

apt-get update
apt-get upgrade -y

# add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# add sql tools repo
curl https://packages.microsoft.com/keys/microsoft.asc > /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# add gh cli repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

apt-get update

export ACCEPT_EULA=y

apt-get install -y apt-utils dialog apt-transport-https ca-certificates software-properties-common
apt-get install -y libssl-dev libffi-dev python2-dev build-essential cifs-utils lsb-release gnupg-agent
apt-get install -y curl git wget nano zsh
apt-get install -y jq zip unzip httpie dnsutils
apt-get install -y dotnet-sdk-7.0 golang
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y mssql-tools unixodbc-dev
apt-get install -y gh

# fix dotnet install issue
cp -r /usr/share/dotnet/* /usr/lib/dotnet/

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# install k3d
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.4.6 bash

# install flux
curl -s https://fluxcd.io/install.sh | bash

# install K9s
VERSION=$(curl -i https://github.com/derailed/k9s/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//')
wget https://github.com/derailed/k9s/releases/download/$VERSION/k9s_Linux_amd64.tar.gz
tar -zxvf k9s_Linux_amd64.tar.gz -C /usr/local/bin
rm -f k9s_Linux_amd64.tar.gz

# install jp (jmespath)
VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//')
wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp
chmod +x /usr/local/bin/jp

# install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# install Kustomize
cd /usr/local/bin
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
cd $OLD_PWD

# change ownership of home directory
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER

# update wsl.conf
printf "\n[user]\ndefault=$SUDO_USER\n" >> /etc/wsl.conf

# start the docker service
service docker start
