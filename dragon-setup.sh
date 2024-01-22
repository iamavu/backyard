#!/bin/zsh

#zsh script to set up kali in desired state, run as kali user

mkdir -p $HOME/hack/{ctf/{pico,random},htb,portswigger,dependencies/{go,openvpn}}
sudo apt install -y golang micro python3-venv libpcap-dev massdns ntp python3-pwntools ghidra seclists dirsearch rizin-cutter dtrx
cd $HOME/hack/dependencies && python3 -m venv py3env 
echo "
\n
export GOPATH=\$HOME/hack/dependencies/go
export PATH=\$PATH:\$GOPATH/bin
alias py3env='source /home/kali/hack/dependencies/py3env/bin/activate'
alias htbl='sudo openvpn /home/kali/hack/dependencies/openvpn/htb-labs.ovpn'
alias update='sudo apt update && sudo apt full-upgrade -y'
junk() 
{
    mv \$1 '/home/kali/.trash'
}

insgcc()
{
    gcc \$1 -fno-stack-protector -z execstack -no-pie && mv a.out \${1%??}

}" >> $HOME/.zshrc
source $HOME/.zshrc
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -ia
source $HOME/.zshrc
go install -v github.com/tomnomnom/unfurl@latest
cd /opt && sudo git clone https://github.com/pwndbg/pwndbg.git && cd pwndbg && sudo ./setup.sh && echo "source /opt/pwndbg/gdbinit.py" > $HOME/.gdbinit


