#!/bin/bash

export MSSQL_SA_PASSWORD=Res-Edge-24
export MSSQL_NAME=localhost:31433

cd $HOME || exit 1

# make some directories we will need
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
mkdir -p $HOME/go/src
mkdir -p $HOME/go/bin
mkdir -p $HOME/.kube
mkdir -p $HOME/bin
mkdir -p $HOME/.k9s

# create sql helper command
{
    echo '#!/bin/zsh'
    echo ""
    echo '/opt/mssql-tools/bin/sqlcmd -d ist -S "$MSSQL_NAME" -U sa -P "$MSSQL_SA_PASSWORD" "$@"'
} > "$HOME/bin/sql"
chmod +x "$HOME/bin/sql"

{
    echo 'cd $HOME'
    echo ""

    echo 'hsort() { read -r; printf "%s\\n" "$REPLY"; sort }'
    echo ""

    echo "export PATH=\$PATH:/opt/mssql-tools/bin:\$HOME/bin:\$HOME/.dotnet/tools:\$HOME/go/bin"
    echo ""

    echo "export PAT=$PAT"
    echo "export GITHUB_TOKEN=\$PAT"
    echo "export KIC_PAT=\$PAT"
    echo ""

    echo "export MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD"
    echo "export MSSQL_NAME=$MSSQL_NAME"
    echo "export DS_URL=http://localhost:32080"
    echo ""

    echo "alias k='kubectl'"
    echo "alias kaf='kubectl apply -f'"
    echo "alias kdelf='kubectl delete -f'"
    echo "alias kl='kubectl logs'"
    echo "alias kak='kubectl apply -k'"
    echo "alias kuse='kubectl config use-context'"
    echo ""

    echo "export GO111MODULE=on"
    echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'"
} > $HOME/.zshenv

{
    echo '#!/bin/bash'
    echo ""
    echo "# show friendly path"
    echo 'echo "$PATH" | sed "s/:/\\n/g"'
} > $HOME/bin/path
chmod +x $HOME/bin/path

# install oh my zsh
bash -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# add to .zshrc
{
    echo ""
    echo 'cd $HOME'
    echo ""
    echo "# start a process so WSL doesn't exit"
    echo "if ! ps -ef | grep \"sleep infinity\" | grep -v grep > /dev/null; then"
    echo "    nohup sleep infinity >& \$HOME/nohup.out &"
    echo "fi"
    echo ""
    echo "compinit"
} >> $HOME/.zshrc


git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab
git config --global pull.rebase false
git config --global init.defaultbranch main
git config --global fetch.prune true
git config --global core.pager more
git config --global diff.colorMoved zebra
git config --global devcontainers-theme.show-dirty 1
git config --global core.editor "nano -w"
git config --global credential.helper store

mkdir -p "$HOME/.oh-my-zsh/completions"
kic completion zsh > "$HOME/.oh-my-zsh/completions/_kic"
ds completion zsh > "$HOME/.oh-my-zsh/completions/_ds"
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"
k3d completion zsh > "$HOME/.oh-my-zsh/completions/_k3d"
kustomize completion zsh > "$HOME/.oh-my-zsh/completions/_kustomize"
#gh completion -s zsh > ~/.oh-my-zsh/completions/_gh
# argocd completion zsh > "$HOME/.oh-my-zsh/completions/_argocd"
# vcluster completion zsh > "$HOME/.oh-my-zsh/completions/_vcluster"
compinit

dotnet tool install --global dotnet-reportgenerator-globaltool --version 5.1.22
dotnet tool install --global webvalidate

docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

exit

### exit from WSL terminal
### run wsl --code ~

# edit and save .zshenv
code $HOME/.zshenv

# change these and run
source $HOME/.zshenv
git config --global user.name bartr
git config --global user.email bartr@microsoft.com
