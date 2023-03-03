#!/bin/bash


while getopts 'hu:r:' OPTION; do
	case "$OPTION" in
		h)
			echo "usage: $(basename $0) -u <user pass> -r <rootpass>" >&1
		        exit 0
		        ;;

		u)
			pass="$OPTARG"
			;;
		r)
			root_pass="$OPTARG"
			;;
		:) 	echo "missing argument for -%s\n" "$OPTARG" >&2;
			echo "usage: $(basename $0) -u <user pass> -r <rootpass>" >&2
		        exit 1
			;;
		?)
			echo "usage: $(basename $0) -u <user pass> -r <rootpass>" >&2
		        exit 1
		       ;;
       esac
done
shift "$(($OPTIND -1))"

if [[ ! "$pass" ]] || [ ! "$root_pass" ];
then
	echo "missing -u and -r flags"
	echo "usage: $(basename $0) -u <user pass> -r <rootpass>" >&2
	exit 1
fi


user="$(whoami)"
BASEOS="$(uname)"
installDIR="$(pwd)"
case $BASEOS in
'Linux')
    BASEOS='Linux'
    ;;
'FreeBSD')
    BASEOS='FreeBSD' #in the making
    alias ls='ls -G'
    ;;
'AIX') ;;
*) ;;
esac

if [[ $BASEOS == "Linux" ]]; 
then
    if $(uname -a | grep -qi "Microsoft"); then
        OS="UbuntuWSL"
    else
        OS=$(lsb_release -i | awk '{ print $3 }')
        if ! command -v lsb_release &> /dev/null; then
            echo "WARNING: Unless using Ubuntu latest, this install might not work"
            echo "lsb_release could not be found, unable to determine your distribution"
            OS="unknown-Linux"
            BASEOS="Linux"
        fi
    fi
    if [[ $OS == "Ubuntu" ]];
    then    
        echo "Installing base packages...."
        echo -e $pass | sudo  -S add-apt-repository -y ppa:longsleep/golang-backports
        echo -e $pass | sudo -S apt-get update -qq

        echo -e $pass | sudo -S DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFNEW=YES  apt-get -y install tor apt-transport-https bundler ca-certificates debian-keyring p7zip zsh unzip zip curl figlet zlib1g-dev python2 python3 default-jdk python3-pip python3-venv libpcap-dev ruby ruby-dev nmap vim dirmngr gnupg-agent gnupg2 libpq-dev software-properties-common golang-go fonts-liberation libappindicator3-1 libcairo2 libgbm1 libgdk-pixbuf2.0-0 libgtk-3-0 libxss1 xdg-utils masscan zmap sqlmap dirb jq ufw neovim ranger bat grc mosh net-tools
    fi
    if [[ $OS == "Debian" ]];
    then
        if groups | grep "\<sudo\>" &> /dev/null; 
        then
            echo "$user is already a sudoer"
        else
            echo "configuring sudo for $user"
            echo $root_pass | /bin/su -l root -c 'apt update && apt upgrade && apt-get install sudo'
            echo $root_pass | /bin/su -l root -c "/usr/sbin/usermod -aG sudo $user"
            echo $root_pass | /bin/su -l root -c "echo '$user   ALL=(ALL:ALL) ALL' | (EDITOR='tee -a' /usr/sbin/visudo)"
        fi
        echo $root_pass | /bin/su -l root -c "echo 'APT::Default-Release \"stable\";' >> /etc/apt/apt.conf "
        echo $root_pass | /bin/su -l root -c "echo 'deb http://deb.debian.org/debian/ stable main' > /etc/apt/sources.list.d/stable.list"
        echo $root_pass | /bin/su -l root -c "echo 'deb-src http://deb.debian.org/debian/ stable main' >> /etc/apt/sources.list.d/stable.list"
        echo $root_pass | /bin/su -l root -c "echo 'deb http://deb.debian.org/debian/ unstable main' > /etc/apt/sources.list.d/unstable.list"
        echo $root_pass | /bin/su -l root -c "echo 'deb-src http://deb.debian.org/debian/ unstable main' >> /etc/apt/sources.list.d/unstable.list"  
        echo -e $pass | sudo -S apt update
        echo -e $pass | sudo -S DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFNEW=YES  apt-get -y install -t stable tor git apt-transport-https ca-certificates debian-keyring bundler p7zip zsh unzip zip curl figlet zlib1g-dev python2 python3 default-jdk python3-pip python3-venv libpcap-dev ruby ruby-dev nmap vim dirmngr gnupg-agent gnupg2 libpq-dev software-properties-common fonts-liberation libappindicator3-1 libcairo2 libgbm1 libgdk-pixbuf2.0-0 libgtk-3-0 libxss1 xdg-utils masscan zmap sqlmap dirb jq ufw neovim ranger grc mosh net-tools bat
        echo -e $pass | sudo -S DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFNEW=YES  apt-get -y install -t unstable golang
    fi
fi

echo "Copying configuration files..."
if [ -d "$HOME/.config" ]
then
    echo "$HOME/.config exists"
else
    mkdir $HOME/.config
fi

cp "./configs/zshrc" "$HOME/.zshrc"
cp "./configs/oh-my-zsh.tar.gz" "$HOME/.oh-my-zsh.tar.gz"
cp "./configs/nvim.tar.gz" "$HOME/.config/nvim.tar.gz"
cp "./configs/tmux.conf" "$HOME/.tmux.conf"
cp "./configs/tmux.conf.local" "$HOME/.tmux.conf.local"

if [[ $(getconf LONG_BIT) == "32" ]];
then
    echo -e $pass | sudo -S DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFNEW=YES  apt-get -y install docker.io
else    
    curl -fsSL get.docker.com | sh 
fi


cd /tmp && wget -O /tmp/gobuster.7z https://github.com/OJ/gobuster/releases/download/v3.0.1/gobuster-linux-amd64.7z && p7zip -d /tmp/gobuster.7z && echo -e $pass | sudo -S mv /tmp/gobuster-linux-amd64/gobuster /usr/bin/gobuster && echo -e $pass | sudo -S chmod +x /usr/bin/gobuster
echo -e $pass | sudo -S wget https://raw.githubusercontent.com/xero/figlet-fonts/master/Bloody.flf -O /usr/share/figlet/Bloody.flf
echo -e $pass | sudo -u $user -S curl https://raw.githubusercontent.com/mitsuhiko/pipsi/master/get-pipsi.py | python3


echo "Cloning Git Repos"
git clone https://github.com/navisecdelta/EmailGen.git $HOME/recon/emailgen
git clone https://github.com/blark/aiodnsbrute.git $HOME/recon/aiodnsbrute
git clone https://github.com/OWASP/Amass.git $HOME/recon/amass
git clone https://github.com/navisecdelta/PwnFile.git $HOME/hashes/pwnfile
git clone https://github.com/lgandx/Responder.git $HOME/hashes/responder
git clone https://github.com/danielmiessler/SecLists.git $HOME/lists/seclists
git clone https://github.com/vortexau/dnsvalidator.git $HOME/recon/dnsvalidator && cd $HOME/recon/dnsvalidator/ && echo -e $pass | sudo -S python3 setup.py install
if [[ $(getconf LONG_BIT) == "32" ]];
then
    echo "skipping massdns installation for depricated 32-bit systems\nmassdns relies on __uint128_t integer type which is not supported on 32-bit systems"
else
    git clone https://github.com/blechschmidt/massdns.git /tmp/massdns; cd /tmp/massdns; make; echo -e $pass | sudo -S mv bin/massdns /usr/bin/massdns 
fi
git clone https://github.com/codingo/Interlace.git $HOME/recon/interlace && cd $HOME/recon/interlace/ && echo -e $pass | sudo -S python3 setup.py install
git clone https://github.com/rofl0r/proxychains-ng.git && cd proxychains-ng && ./configure --prefix=/usr --sysconfdir=/etc && echo -e $pass | sudo -S make && echo -e $pass | sudo -S make install && cd .. && echo -e $pass | sudo -S rm -r proxychains-ng
git clone https://github.com/securing/DumpsterDiver.git $HOME/recon/DumpsterDiver && cd $HOME/recon/DumpsterDiver && pip3 install --ignore-installed -r requirements.txt
git clone https://github.com/1ndianl33t/Gf-Patterns $HOME/.gf
git clone https://github.com/projectdiscovery/nuclei-templates $HOME/recon/nuclei
git clone https://github.com/projectdiscovery/nuclei.git; cd nuclei/v2/cmd/nuclei/; go build; echo -e $pass | sudo -S mv nuclei /usr/local/bin/


echo "Downloading Wordlists..."
wget -O $HOME/lists/jhaddix-all.txt https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt
wget -O $HOME/lists/resolvers.txt https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt


echo "Configuring ZSH"
cd $HOME && tar -xf $HOME/.oh-my-zsh.tar.gz
cd $HOME/.config/ && tar -xf $HOME/.config/nvim.tar.gz
cd $HOME/recon/emailgen && echo -e $pass | sudo -S bundle update --bundler
cd $HOME/recon/emailgen && echo -e $pass | sudo -S bundle install

if [ -f "/usr/bin/zsh" ]
then 
    echo -e $pass | sudo -S chsh -s $(which zsh) $user
else
    echo "zsh failed to install, check the problem manually"
fi
echo 'Installing Neovim Plugin manager'
echo -e $pass | sudo -u $user -S curl --create-dirs -fLo ~/.local/share/nvim/site/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ -d "$HOME/go/bin" ]
then
    echo "$HOME/go/bin exists"
else
    mkdir $HOME/go/bin
fi

echo 'Installing Go Tools'
for line in $(cat $installDIR/configs/go-tools.json | jq -r '.go[] | select(.v11=="false") | [.name,.url,.author] | @csv')
do 
    name="$(echo $line | cut -d "," -f 1 | tr -d '"')"
    url="$(echo $line | cut -d "," -f 2 | tr -d '"')"
    author="$(echo $line | cut -d "," -f 3 | tr -d '"')"

    echo "Instaling '$name' by '$author'..."
    echo -e $pass | sudo -u $user -S go install $url@latest
done


wget -O /tmp/aquatone.zip https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip && cd /tmp/ && unzip /tmp/aquatone.zip && mv /tmp/aquatone $HOME/go/bin/aquatone
wget -O /tmp/amass.zip https://github.com/OWASP/Amass/releases/download/v3.9.1/amass_linux_amd64.zip && cd /tmp/ && unzip /tmp/amass.zip && mv /tmp/amass_linux_amd64/amass $HOME/go/bin/amass
echo -e $pass | sudo -u $user -S mkdir -p $HOME/go/src/github.com/zmap/ && git clone https://github.com/zmap/zdns.git $HOME/go/src/github.com/zmap/zdns  && cd $HOME/go/src/github.com/zmap/zdns/ && go build && go install

touch $HOME/.profile
touch $HOME/.z

if [[ $(cat /etc/group | grep users) == "" ]];
then
    echo -e $pass | sudo -S groupadd users
fi

echo -e $pass | sudo -S usermod -aG users $user 
echo -e $pass | sudo -S chgrp -R users $HOME 
echo -e $pass | sudo -S chown -R $user $HOME
