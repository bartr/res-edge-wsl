# Deploying Res-Edge on WSL

- Read more about [Res-Edge](https://res-edge.com)
- You need access to `pizza-labs` in order to complete this lab
  - Ping `bartr@microsoft.com` if you think you should have access

## Install WSL (version 2)

- From an elevated Command Prompt
  - You may have to run --update multiple times
  - `wsl --update`
    - The most recent version of Windows Subsystem for Linux is already installed.
  - Set WSL to always use verion 2
    - `wsl --set-default-version 2`

## Start Ubuntu in WSL

- `wsl --install ubuntu`
- Enter your user name and password

## Update IP Tables

```bash

clear
echo "choose Legacy IP Tables"
echo ""

sudo update-alternatives --config iptables

```

## Set root password

```bash

echo ""
echo "set the root password"
sudo passwd

```

## Set environment variables

```bash

# your PAT should have access to the GitOps repo Res-Edge uses
export PAT=MyGitHubPat

```

## Set git config

- change the values

```bash

git config --global user.name bartr
git config --global user.email bartr@microsoft.com

```

## Set git-credentials

```bash

git config --global credential.helper store
echo "https://$(git config user.name):$PAT@github.com" > $HOME/.git-credentials

```

## Clone pizza-labs

```bash

# clone pizza-labs
### change bartr to your branch
cd $HOME

git clone https://github.com/cse-labs/pizza-labs
cd pizza-labs
git checkout bartr
git pull
cp -r .kic ..
cp -r .ds ..
git clone https://github.com/cse-labs/pizza-labs .gitops
cd .gitops
git checkout labs --
git pull
cd $HOME

```

## Clone this repo

```bash

cd $HOME

git clone https://github.com/bartr/res-edge-wsl wsl
cd wsl

```

## Install components

```bash

sudo ./install.sh

```

## Configure User

```bash

./config.sh

```

## Finish Setup

- `exit` the WSL shell
- Restart the WSL shell with `wsl`

```bash

mkdir -p "$HOME/.oh-my-zsh/completions"
kic completion zsh > "$HOME/.oh-my-zsh/completions/_kic"
ds completion zsh > "$HOME/.oh-my-zsh/completions/_ds"
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"
k3d completion zsh > "$HOME/.oh-my-zsh/completions/_k3d"
kustomize completion zsh > "$HOME/.oh-my-zsh/completions/_kustomize"
compinit

```

## Install Local Container Registry

```bash

docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

```

## Create a Cluster

- This will create the k3d cluster
- It will also install Flux and configure as `lab-01`

```bash

cd $HOME/pizza-labs

kic cluster create

```

## Test Cluster

```bash

http localhost

http localhost/heartbeat/16

```

- Using your browser, go to <http://localhost> and <http://locahost/heartbeat/16>
- Use <https://res-edge.com> to deploy / undeploy Namespaces to `/m/type/lab`
