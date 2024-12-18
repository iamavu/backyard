#!/bin/zsh

#zsh script to set up linux installation to desired state, run as default user

#make directories
mkdir -p $HOME/hack/{ctf/{pico,random},htb,portswigger,dependencies/{go,openvpn}}

#install crucial stuff
sudo apt-get update
sudo apt-get install -y ca-certificates curl git golang micro python3-venv libpcap-dev ntp python3-pwntools dirsearch dtrx alacarte jq xxd gcc-multilib g++-multilib zsh-autosuggestions zsh-syntax-highlighting zsh openjdk-24-jdk

#setup oh-my-zsh and it's plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)/g' ~/.zshrc;

#create virtual python3 environment
cd $HOME/hack/dependencies && python3 -m venv py3env 

#edit zshrc with needed stuff
echo "
\n
export GOPATH=\$HOME/hack/dependencies/go
export PATH=\$PATH:\$GOPATH/bin
alias py3env='source \$HOME/hack/dependencies/py3env/bin/activate'
alias htbl='sudo openvpn \$HOME/hack/dependencies/openvpn/htb-labs.ovpn'
alias update='sudo apt update && sudo apt full-upgrade -y'
alias repy3='rm -rf \$HOME/hack/dependencies/py3env/ && python3 -m venv \$HOME/hack/dependencies/py3env/ && source \$HOME/hack/dependencies/py3env/bin/activate'
junk()
{
    if [ ! -d "$HOME/.trash" ]; then
        mkdir -p "$HOME/.trash"
    fi
    
    for item in "$@"; do
        if [ -e "$item" ]; then
            mv "$item" "$HOME/.trash"
        else
            echo "WARNING: '$item' does not exist"
        fi
    done
}
" >> $HOME/.zshrc
source $HOME/.zshrc

#install project discovery tools
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -ia
source $HOME/.zshrc

#install pwndbg
cd /opt && sudo git clone https://github.com/pwndbg/pwndbg.git && sudo chown -R $USER pwndbg && cd pwndbg && ./setup.sh && echo "source /opt/pwndbg/gdbinit.py" > $HOME/.gdbinit

#install croc
curl https://getcroc.schollz.com | bash

#setup nuclei and change user from 'ubuntu' to required user
nuclei
echo "
	{
	  "nuclei-templates-directory": "/home/ubuntu/.nuclei-templates",
	  "custom-s3-templates-directory": "/home/ubuntu/.nuclei-templates/s3",
	  "custom-github-templates-directory": "/home/ubuntu/.nuclei-templates/github",
	  "custom-gitlab-templates-directory": "/home/ubuntu/.nuclei-templates/gitlab",
	  "custom-azure-templates-directory": "/home/ubuntu/.nuclei-templates/azure",
	  "nuclei-templates-version": "v10.1.0",
	  "nuclei-ignore-hash": "be607ea3cf572df815046a76651c4884",
	  "nuclei-latest-version": "v3.3.7",
	  "nuclei-templates-latest-version": "v10.1.0",
	  "nuclei-latest-ignore-hash": "be607ea3cf572df815046a76651c4884"
	}
" > $HOME/.config/nuclei/.templates-config.json

#install seclists
cd /opt && sudo git clone https://github.com/danielmiessler/SecLists.git && sudo chown -R $USER SecLists && sudo mv SecLists seclists