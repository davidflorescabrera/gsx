#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 24/03/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) backup_interfaces.sh fitxer \n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Ens copia el fitxer resolv.conf i el fitxer interfaces a una carpeta nova anomenada /gsx/network per tal de tenir una copia de 
seguretat dels fitxers\n
Ubicació de l'script: /gsx\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comprovació número de parámetres
if [ $# -gt 1 ]; then
	echo "Us: ./backup_interfaces.sh"
     	exit 1
fi

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

#Comprovació usuari root
if [ $EUID -ne 0 ]; then
	echo "Aquest script ha de ser executat com a root"
	exit 1
fi

if [ ! -d "/gsx" ]; then
	mkdir /gsx
	mkdir /gsx/network
fi

if [ ! -d "/gsx/network" ]; then
	mkdir /gsx/network
fi

cp -p /etc/resolv.conf /gsx/network/
cp -p /etc/network/interfaces /gsx/network/
iptables-save > /gsx/network/iptables
