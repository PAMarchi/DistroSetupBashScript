#!/bin/bash
#Este é um script dedicado ao pós instalação de distros Linux, onde serão instalados programas essenciais e realizadas configurações no sistema

#Variáveis
OS=/etc/os-release
DISTRO=""

CheckDistro(){
	if grep -qi "debian" $OS || grep -qi "ubuntu" $OS; then
		DISTRO=debian
		return 0
	
	elif grep -qi "arch" $OS; then
		DISTRO=arch
		return 0
	
	elif grep -qi "fedora" $OS || grep -qi "rhel" $OS; then
		DISTRO=redhat
		return 0

	elif grep -qi "alpine" $OS; then
		DISTRO=alpine
		return 0	

	else
		exit 1
	
	fi
}

Update_Upgrade(){
	if [ "$DISTRO" = "debian" ]; then
		sudo apt update && sudo apt dist-upgrade -y || sudo apt upgrade -y

	elif [ "$DISTRO" = "arch" ]; then
		exit 1 #No support yet

	elif [ "$DISTRO" = "redhat" ]; then
		sudo dnf update && sudo dnf upgrade -y

	elif [ "$DISTRO" = "alpine" ]; then
		exit 1 #No support yet 
	
	fi
}

Install_Basics(){
	if [ "$DISTRO" = "debian" ]; then
	
		#Installing Flatpak
		sudo apt install flatpak -y

		#Installing Flatpak Store
		if [ "$DESKTOP_SESSION" = "gnome" ]; then
			sudo apt install gnome-software-plugin-flatpak -y

		else
			sudo apt install plasma-discover-backend-flatpak -y

		fi

		#Enabling FlatHub Repo
		sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

		#Enabling Non-free Repo
		sudo apt install software-properties-common -y
		sudo apt-add-repository contrib non-free-firmware
		
		#Installing Media Codecs
		sudo apt install libavcodec-extra vlc -y

		sudo apt install firefox git python3 fastfetch -y && sudo pip3 install jupyter --no-input

	elif [ "$DISTRO" = "arch" ]; then
		
		#Installing Flatpak
		sudo pacman -S flatpak --noconfirm

	elif [ "$DISTRO" = "redhat" ]; then

		#Installing RPM Repo
		sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y && sudo dnf update @core -y

		#Enabling FlatHub Repo
		sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

		#Installing Media Packages
		sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
		sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
		sudo dnf install intel-media-driver -y
		sudo dnf install libva-nvidia-driver -y

		sudo dnf install firefox git python3 fastfetch -y && sudo pip3 install jupyter --no-input

	elif [ "$DISTRO" = "alpine" ]; then
		
		#Installing Flatpak
		doas apk add flatpak

		#Installing Flatpak Store
		if [ "$DESKTOP_SESSION" = "gnome" ]; then
			doas apk add gnome-software-plugin-flatpak

		else
			doas apk add discover-backend-flatpak

		fi

		#Enabling FlatHub Repo
		doas flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	
	fi
}

Install_Others(){
	if [ "$DISTRO" = "debian" ]; then
		
		#Installing VS Code
		sudo wget -O code-latest.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
		sudo apt install ./code-latest.deb
		sudo rm code-latest.deb
		
		sudo apt install wireshark tor torbrowser-launcher -y

		sudo flatpak install bitwarden md.obsidian.Obsidian winbox -y

	elif [ "$DISTRO" = "arch" ]; then
		exit 1

	elif [ "$DISTRO" = "redhat" ]; then
		
		#For VS Code installation
		sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
		echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

		sudo dnf install code wireshark tor torbrowser-launcher -y

		sudo flatpak install bitwarden md.obsidian.Obsidian winbox -y

	elif [ "$DISTRO" = "alpine" ]; then
		exit 1
	
	fi
}

###############################################

echo Qual será o hostname?
read -r HOSTNAME

#Checa qual a distro

CheckDistro

#Tweaks

if [ "$DISTRO" = "debian" ]; then
	
	#Change Hostname
	sudo hostnamectl set-hostname "$HOSTNAME"

elif [ "$DISTRO" = "arch" ]; then
	exit 1

elif [ "$DISTRO" = "redhat" ]; then

	#Dnf configs
	(echo "fastestmirror=True"; echo "defaultyes=True") | sudo tee -a /etc/dnf/dnf.conf > /dev/null

	#Change Hostname
	sudo hostnamectl set-hostname "$HOSTNAME"

elif [ "$DISTRO" = "alpine" ]; then
	exit 1
	
fi

Update_Upgrade
Install_Basics
Install_Others
