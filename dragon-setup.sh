#!/bin/zsh

#zsh script to set up kali in desired state, run as kali user

#make directories
mkdir -p $HOME/hack/{ctf/{pico,random},htb,blogs,portswigger,dependencies/{go,openvpn}}

#install crucial stuff
sudo apt-get update
sudo apt-get install -y ca-certificates curl golang micro python3-venv libpcap-dev massdns ntp python3-pwntools ghidra seclists dirsearch rizin-cutter dtrx alacarte jq

#create virtual python3 environment
cd $HOME/hack/dependencies && python3 -m venv py3env 

#edit zshrc with needed stuff
echo "
\n
export GOPATH=\$HOME/hack/dependencies/go
export PATH=\$PATH:\$GOPATH/bin
alias py3env='source /home/kali/hack/dependencies/py3env/bin/activate'
alias htbl='sudo openvpn /home/kali/hack/dependencies/openvpn/htb-labs.ovpn'
alias update='sudo apt update && sudo apt full-upgrade -y'
alias repy3='rm -rf /home/kali/hack/dependencies/py3env/ && python3 -m venv /home/kali/hack/dependencies/py3env/ && source /home/kali/hack/dependencies/py3env/bin/activate'
alias rnm='sudo systemctl restart NetworkManager.service'
junk() 
{
    mv \$1 '/home/kali/.trash'
}

insgcc()
{
    gcc \$1 -fno-stack-protector -z execstack -no-pie && mv a.out \${1%??}

}" >> $HOME/.zshrc
source $HOME/.zshrc

#install project discovery tools
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -ia
source $HOME/.zshrc

#install unfurl
go install -v github.com/tomnomnom/unfurl@latest

#install pwndbg
cd /opt && sudo git clone https://github.com/pwndbg/pwndbg.git && cd pwndbg && sudo ./setup.sh && echo "source /opt/pwndbg/gdbinit.py" > $HOME/.gdbinit

