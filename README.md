# Deploying Res-Edge on WSL

- Read more about [Res-Edge](https://res-edge.com)
- You need access to `pizza-labs` in order to complete this lab
  - Ping `bartr@microsoft.com` if you think you should have access

## Install WSL (version 2)

- From an elevated Command Prompt
  - You may have to run --update multiple times

    ```bash
    wsl --update
    ```

    - The most recent version of Windows Subsystem for Linux is already installed.
  - Set WSL to always use verion 2

    ```bash
    wsl --set-default-version 2
    ```

## Start Ubuntu in WSL

- Enter your user name and password
  - Using the same user name as Windows will make things easier

  ```bash

  set USERNAME

  wsl --install ubuntu

  ```

## Update IP Tables

- Once WSL starts, you will be in a bash prompt inside your Ubuntu VM
- You will have to enter you're password the first time you run `sudo`

```bash

echo "choose Legacy IP Tables"
echo ""

sudo update-alternatives --config iptables

```

## Set root password

- Set the `root` password to something you can remember - in case you need it

```bash

echo ""
echo "set the root password"
sudo passwd

```

## Set environment variables

- Your PAT should have access to the GitOps repo Res-Edge uses

> Do NOT check your PAT into GitHub!!!

```bash

export PAT=MyGitHubPat

```

## Set git config

- Change the values

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
### some of the WSL changes are only in the bartr branch
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

# install tools
sudo ./install.sh

# Configure User
./config.sh

```

## AKS EE Client Setup

- If you are using this image as a bash shell to manage AKS EE, you have to complete these steps

### Update vSwitch
- This step allows the vSwitches to communicate
- If you used a differnt vSwitch, change before running
- From an elevated PowerShell (on the Windows host) prompt

```powershel

Get-NetIPInterface | where {$_.InterfaceAlias -eq 'vEthernet (WSL)' -or $_.InterfaceAlias -eq 'vEthernet (aksedgesw-int)'} | Set-NetIPInterface -Forwarding Enabled -Verbose

```

### Copy Kubectl Config

- From your WSL SSH session
- You may have to update the path

```bash

cd $HOME
mkdir -p .kube
cp /mnt/c/Users/$USER/.kube/config .kube

```

## Finish Setup

- `exit` the WSL shell
- Restart the WSL shell

  ```bash
  wsl -- code ~
  ```

- Use "ctl `" to open a terminal

```bash

mkdir -p "$HOME/.oh-my-zsh/completions"
kic completion zsh > "$HOME/.oh-my-zsh/completions/_kic"
ds completion zsh > "$HOME/.oh-my-zsh/completions/_ds"
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"
k3d completion zsh > "$HOME/.oh-my-zsh/completions/_k3d"
kustomize completion zsh > "$HOME/.oh-my-zsh/completions/_kustomize"
gh completion zsh > "$HOME/.oh-my-zsh/completions/_gh"
flux completion zsh > "$HOME/.oh-my-zsh/completions/_flux"
compinit

```

## Check AKS EE Cluster

- This will only work if you setup the AKS EE cluster

```bash

kic pods

```

## Create a Cluster

- This will create the k3d cluster
- It will also install Flux and configure as `lab-01`

```bash

cd $HOME/pizza-labs

kic cluster create

```

## Test the Cluster

```bash

http localhost

http localhost/heartbeat/16

```

- Using your browser, go to <http://localhost> and <http://localhost/heartbeat/16>
- Use <https://res-edge.com> to deploy / undeploy Namespaces to `/m/type/lab`

## Save the Image (optional)

- Use WSL to save the image for reuse
- Exit WSL into the Command Prompt
- Change to the directory you want to store the file (3 - 8 GB)

```bash

# delete the cluster (optional)
wsl -- kic cluster delete

# stop the instance
wsl -t ubuntu

# export the image
wsl --export ubuntu kic.tar

# unregister ubuntu
wsl --unregister ubuntu

# import the image as "kic" - store in ./kic
wsl --import kic kic kic.tar

# start the image
# run kic cluster create if you deleted the cluster
# copy the AKS EE .kube/config file if running as client
wsl -- code ~

```

## Stop the WSL Instance

```bash

wsl -t ubuntu

```

## Destroy the WSL Instance

```bash

wsl --unregister ubuntu

```

## Support

This project uses GitHub Issues to track bugs and feature requests. Please search the existing issues before filing new issues to avoid duplicates.  For new issues, file your bug or feature request as a new issue.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.
