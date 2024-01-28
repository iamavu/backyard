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

#install docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  mantic stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
