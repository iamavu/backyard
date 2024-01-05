#!/bin/zsh

#zsh script to set up kali in desired state, run as kali user

mkdir -p $HOME/Hack/{ctf/{pico,random},htb,portswigger,dependencies/{go,openvpn}}
sudo apt install -y golang micro python3-venv libpcap-dev massdns python3-pwntools ghidra seclists
cd $HOME/Hack/dependencies && python3 -m venv py3env 
echo "export GOPATH=$HOME/Hack/dependencies/go
export PATH=$PATH:$GOPATH/bin
alias py3env='source /home/kali/Hack/dependencies/py3env/bin/activate'" >> $HOME/.zshrc
source $HOME/.zshrc
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -ia
source $HOME/.zshrc
go install -v github.com/tomnomnom/unfurl@latest
cd /opt && sudo git clone https://github.com/pwndbg/pwndbg.git && cd pwndbg && sudo ./setup.sh && echo "source /opt/pwndbg/gdbinit.py" > $HOME/.gdbinit


