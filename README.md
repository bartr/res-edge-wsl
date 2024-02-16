# Deploying Res-Edge on WSL

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

## Clone this repo

```bash

cd $HOME

git clone https://github.com/bartr/res-edge-wsl wsl
cd wsl

```

## Set environment variables

```bash

# your PAT should have access to the GitOps repo Res-Edge uses
export PAT=MyGitHubPat

```

## Install components

```bash

sudo ./install.sh

```

## Configure User

```bash

./config.sh

```
