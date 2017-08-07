#!/bin/bash

which sudo >/dev/null
if [[ $? == 1 ]]; then
	echo "Sudo is not installed! Please login as root and install sudo using 'pacman -S sudo'"
	return
fi

if [[ $1 == "-y" ]]
then
	allyes=true
else
	allyes=false
fi


T1=$(tput setaf 1)
T2=$(tput setaf 2)
T3=$(tput setaf 3)
T4=$(tput setaf 4)
T5=$(tput setaf 5)
T6=$(tput setaf 6)
T7=$(tput setaf 7)

Tb=$(tput bold)

Tr=$(tput sgr 0 0)

echo "${Tb}${T2}This is an installation script. ${T1}Use it with caution${Tr}"

declare -a headers=(
	"\n${Tb}${T6}Time zone${Tr}" 		""
	"\n${Tb}${T6}Locale${Tr}" 		"" "" ""
	"\n${Tb}${T6}Hostname${Tr}" 		""
	"\n${Tb}${T4}Install software${Tr}" 	"" "" "" "" "" "" "" ""
	)

declare -a messages=(
	"Set timezone to Europe/Helsinki"
	"Run hwclock(8) to generate /etc/adjtime"

	"Uncomment #en_US... in /etc/locale.gen"
	"Generate the locales"
	"Set the LANG variable in locale.conf as en_US.UTF-8"
	"Set the keyboard layout in vconsole.conf"

	"Create the hostname file"
	"Add the hostname into /etc/hosts"

	"Install and enable NetworkManager"
	"Install xorg-server for X based desktops"
	"Install the perfect graphics driver (show VGA device from lspci)"
	"Install and enable sddm"
	"Install alsa-utils"
	"Install mesa"
	"Install xf86-input-synaptics (laptop trackpad drivers)"
	"Install a simple X desktop environment"
	"Install ttf-dejavu"
	)

declare -a commands=(
	"sudo ln -sf /usr/share/zoneinfo/Europe/Helsinki /etc/localtime"
	"sudo hwclock --systohc"

	"sudo sed -e 's/#en_US/en_US/g' /etc/locale.gen > /tmp/locale.gen; sudo cp /tmp/locale.gen /etc/locale.gen"
	"sudo locale-gen"
	"echo LANG=en_US.UTF-8 | sudo tee /etc/locale.conf"
	"echo KEYMAP=fi | sudo tee /etc/vconsole.conf"

	"read -p 'Hostname: ' hname; echo \$hname | sudo tee /etc/hostname"
	"awk -v var=\"\$(cat /etc/hostname)\" '/::1/ && !x {print \"127.0.1.1\t\"var\".localdomain\t\"var; x=1} 1' /etc/hosts > /tmp/hosts; sudo cp /tmp/hosts /etc/hosts"

	"if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then echo \"${T2}Web reachable!${Tr}\"; else echo \"${T1}Web unreachable!${Tr}\";fi; sudo pacman -S networkmanager; sudo systemctl enable NetworkManager.service"
	"sudo pacman -S xorg-server"
	"lspci |grep VGA; readarray -t content <<< \"\$(pacman -Ss xf86-video- |grep xf86-video- |sed 's/.*\///;s/ .*//')\"; for ((j=0; j<\${#content[@]}; j++)); do content[\$j]=\"\$(echo -e \"\${content[\$j]}\" | sed 's/\\xc2\\xa0//g')\"; echo \"  ${T5}\${j})${Tr} \${content[\$j]}\"; done; echo; read -p \"Enter a selection ${T5}(default=None)${Tr}: \" selection; case \$selection in *[0-9]*) if [ \"\$selection\" -ge 0 -a \"\$selection\" -lt \${#content[@]} ]; then sudo pacman -S \${content[\$selection]}; else echo \"${T1}Invalid number!${Tr}\";fi ;; *) echo \"${T5}Nothing chosen...${Tr}\" ;; esac"
	"sudo pacman -S sddm; sudo systemctl enable sddm"
	"sudo pacman -S alsa-utils"
	"sudo pacman -S mesa"
	"sudo pacman -S xf86-input-synaptics"
	"sudo pacman -S xorg-twm xorg-xclock xterm"
	"sudo pacman -S ttf-dejavu"
	)

for (( i=0; i<${#messages[@]}; i++ )); do
	if [[ "${headers[$i]}" != "" ]]; then
		echo -e "${Tb}${headers[$i]}${Tr}"
	fi

	if [ "$allyes" = false ]; then
		printf "${messages[$i]} ${T3}(Y/n)${Tr} " 
		read choice
	else
		echo "${messages[$i]} ${T3}(Y/n) y${Tr}"
		choice="y"
	fi

	case "$choice" in
		y|Y ) eval "${commands[$i]}" ;;
		* ) echo "${T5}skip...${Tr}"; continue ;;
	esac
done
