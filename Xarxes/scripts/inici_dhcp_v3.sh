#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 24/03/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) ./inici_dhcp_v2.sh rol pathFitxers pathScripts [serverMacAdress] [IPExterna]\nOn el rol pot ser client, router o servidor. Si es router a mes a mes s'ha d'especificar la MAC del servidor. \n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Aquest script el que fa és copiarnos la configuració per l'interfaces depenent si som un router o un client. (client i servidor)\n
En cas de estar a la configuració del router copiarem la MAC que se'ns proporciona per paràmetre al fitxer dhcp.conf al lloc necessàri, tot activant\n
el servei isc-dhcp-server i possant a 1 el ip_forward.\nTambé es configurarà el servei DNS.
Ubicació de l'script: /gsx\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

if ! (([ "$1" == "router" ] && [ $# -eq 5 ]) || ([ "$1" == "client" ] && [ $# -eq 3 ]) || ([ "$1" == "server" ] && [ $# -eq 3 ]));then
		echo -e "Ús: ./inici_dhcp_v2.sh rol pathFitxers pathScripts [serverMacAdress]\nOn el rol pot ser client, router o servidor. Si es router a mes a mes s'ha d'especificar la MAC del servidor."
	exit 1
fi

#Comprovació usuari root
if [ $EUID -ne 0 ]; then
	echo "Aquest script ha de ser executat com a root"
	exit 1
fi

pathFiles="$2"
pathScripts="$3"

if [ ! -e "$pathScripts"/backup_interfaces.sh ]; then
		echo "El fitxer backup_interfaces.sh no existeix. S'ha d'afegir al directori $pathFiles" >&2
		exit 1
fi

files=( "interfacesRouter" "dhcpd.conf" "named.conf.local" "named.conf.options" "db.grup12.gsx" "grup12.gsx.db" "db.interna" "interna48.db" "interna49.db" "resolv.conf" "/webserver/taller.conf" "/webserver/tenda.conf" "/webserver/www/html/index.html" "/webserver/www/taller/index.html" "/webserver/www/tenda/index.html" "/webserver/www/taller/.htaccess" "/webserver/www/taller/.htpasswd")
paquets=( "isc-dhcp-server" "bind9" "bind9-doc" "dnsutils" "openssh-server")

read -p "Abans de seguir, vols realitzar una copia de seguretat de la configuració actual? [s/n]" </dev/tty
if [[ $REPLY =~ [sSyY] ]]; then
		"$pathScripts"/backup_interfaces.sh
		if [ "$?" == "0" ]; then
			echo "Backup realitzat correctament"
		else
			echo "Error al realitzar backup, exiting"
			exit 1
		fi
fi

ifconfig docker0 down
apt-get install openssh-server

case $1 in
router)

	for i in "${files[@]}"
	do
		if [ ! -e "$pathFiles"/"$i" ]; then
				echo "El fitxer $i no existeix. S'ha d'afegir al directori $pathFiles" >&2
				exit 1
		fi
	done

	apt-get update

	for i in "${paquets[@]}"
	do
		apt-get install "$i"
	done

	ifdown eth0
	read -n 1 -p "Conecta el cable d'eth0 i prem qualsevol tecla" </dev/tty
	echo ""


	ifdown eth2
	read -n 1 -p "Conecta el cable d'eth2 i prem qualsevol tecla" </dev/tty
	echo ""

	cp -p "$pathFiles"/interfacesRouter /etc/network/interfaces
	cp -p "$pathFiles"/dhcpd.conf /etc/dhcp/dhcpd.conf
	sed -i 's/%%MAC_address%%/'$4'/g' /etc/dhcp/dhcpd.conf
	ifup eth0
	ifup eth2
	/etc/init.d/isc-dhcp-server restart

	echo "1" > /proc/sys/net/ipv4/ip_forward

	num1=$(echo "$5" | cut -d'.' -f 1)
	num2=$(echo "$5" | cut -d'.' -f 2)
	num3=$(echo "$5" | cut -d'.' -f 3)
	num4=$(echo "$5" | cut -d'.' -f 4)

	cp -p "$pathFiles"/named.conf.local /etc/bind/named.conf.local
	sed -i 's/%%NUM1%%/'$num1'/g' /etc/bind/externa.db
	sed -i 's/%%NUM2%%/'$num2'/g' /etc/bind/externa.db
	sed -i 's/%%NUM3%%/'$num3'/g' /etc/bind/externa.db


	cp -p "$pathFiles"/named.conf /etc/bind/named.conf
	cp -p "$pathFiles"/named.conf.options /etc/bind/named.conf.options
	cp -p "$pathFiles"/db.grup12.gsx /etc/bind/db.grup12.gsx
	cp -p "$pathFiles"/grup12.gsx.db /etc/bind/grup12.gsx.db
	cp -p "$pathFiles"/interna48.db /etc/bind/interna48.db
	cp -p "$pathFiles"/interna49.db /etc/bind/interna49.db

	cp -p "$pathFiles"/externa.db /etc/bind/externa.db
	sed -i 's/%%NUM%%/'$num4'/g' /etc/bind/externa.db

	cp -p "$pathFiles"/db.externa /etc/bind/db.externa
	sed -i 's/%%IP_Externa%%/'$5'/g' /etc/bind/db.externa

	cp -p "$pathFiles"/db.interna /etc/bind/db.interna
	cp -p "$pathFiles"/resolv.conf /etc/resolv.conf

	/etc/init.d/bind9 restart

	iptables -t nat -A POSTROUTING -s 192.168.48.0/23 -o eth1 -j MASQUERADE
 	iptables -t nat -A POSTROUTING -s 172.17.12.0/24 -o eth1 -j MASQUERADE
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 172.17.12.2
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 443 -j DNAT --to-destination 172.17.12.2
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 23 -j DNAT --to-destination 172.17.12.2:22

	echo "Vols comprovar connexió amb el pc1 i la tenda?"
	read -p "Es fara ping fins a obtenir resposta. (maxim 10 pings) [s/n] " </dev/tty

	if [[ $REPLY =~ [sSyY] ]]; then

		echo -ne "\nComprovant connexió amb pc1 "
		i=0
		ping -c 1 pc1.interna > /dev/null 2>&1
		while [ "$?" != "0" ] && [ $i -lt 10 ]; do
			echo -n "·"
			let i=i+1
			sleep 1
			ping -c 1 pc1 > /dev/null 2>&1
		done
		if [ "$?" == "0" ]; then
			echo -e "\nConnexió amb pc1 establerta!"
		else
			echo -e "\nLa connexió no s'ha pogut establir\n."
		fi

		echo -ne "\nComprovant connexió amb taller "
		i=0
		ping -c 1 taller > /dev/null 2>&1
		while [ "$?" != "0" ] && [ $i -lt 10 ]; do
			echo -n "·"
			let i=i+1
			sleep 1
			ping -c 1 taller > /dev/null 2>&1
		done
		if [ "$?" == "0" ]; then
			echo -e "\nConnexió amb taller establerta!"
		else
			echo -e "\nLa connexió no s'ha pogut establir.\n"
		fi
	fi
	;;
client|server)


	if [ ! -e "$pathFiles"/interfacesClient ]; then
			echo "El fitxer interfacesClient no existeix. S'ha d'afegir al directori $pathFiles" >&2
			exit 1
	fi

	ifdown eth1
	read -n 1 -p "Desconecta el cable d'eth1 i prem qualsevol tecla" </dev/tty
	echo ""

	if [ $(mii-tool eth1 | awk '{ print $NF }') == "ok" ]; then
		echo "El cable no ha estat desconectat" >&2
		exit 1
	fi

	ifdown eth0
	read -n 1 -p "Conecta el cable d'eth0 i prem qualsevol tecla" </dev/tty
	echo ""

	if [ $(mii-tool eth0 | awk '{ print $NF }') != "ok" ]; then
		echo "El cable no ha estat conectat" >&2
		exit 1
	fi

	cp -p "$pathFiles"/interfacesClient /etc/network/interfaces
	ifup eth0

	if [ "$1" == "server" ]; then
		rm -r /var/www/*
		cp -rp "$pathFiles"/webserver/www/* /var/www/
		cp -p "$pathFiles"/webserver/taller.conf /etc/apache2/sites-available/taller.conf
		cp -p "$pathFiles"/webserver/tenda.conf /etc/apache2/sites-available/tenda.conf
		a2ensite tenda
		a2ensite taller
		service apache2 start
	fi

	echo "Vols comprovar connexió amb el router?"
	read -p "Es fara ping fins a obtenir resposta. (maxim 10 pings) [s/n] " </dev/tty

	if [[ $REPLY =~ [sSyY] ]]; then

		echo -ne "\nComprovant connexió amb ns "
		i=0
		ping -c 1 ns > /dev/null 2>&1
		while [ "$?" != "0" ] && [ $i -lt 10 ]; do
			echo -n "·"
			let i=i+1
			sleep 1
			ping -c 1 ns > /dev/null 2>&1
		done
		if [ "$?" == "0" ]; then
			echo -e "\nConnexió amb router establerta!"
		else
			echo -e "\nLa connexió no s'ha pogut establir\n."
		fi
	fi

esac
