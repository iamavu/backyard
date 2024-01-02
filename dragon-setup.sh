#!/bin/zsh

#zsh script to set up kali in desired state, run as kali user

mkdir -p $HOME/Hack/{ctf/pico,htb,portswigger,dependencies/{go,openvpn}}
sudo apt install -y golang micro python3-venv libpcap-dev massdns
cd $HOME/Hack/dependencies && python3 -m venv py3env 
echo "export GOPATH=$HOME/Hack/dependencies/go
export PATH=$PATH:$GOPATH/bin
alias py3env='source /home/kali/Hack/dependencies/py3env/bin/activate'" >> $HOME/.zshrc
source $HOME/.zshrc
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -ia
source $HOME/.zshrc
go install -v github.com/tomnomnom/unfurl@latest


