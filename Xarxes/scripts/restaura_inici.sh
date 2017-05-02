#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 24/03/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) restaura_inici.sh \n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Restaura la informació que tenim guardada feta pel backup_interfaces.sh a la carpeta /gsx/network \n
Ubicació de l'script: /gsx\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comprovació número de parámetres
if [ $# -gt 1 ]; then
	echo "Us: bfit.sh fitxer"
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

if [ ! -e "/gsx/network/resolv.conf" ]; then
  echo "No hi ha cap backup a /gsx/network/ del fitxer resolv.conf"  >&2
  exit 1
fi

if [ ! -e "/gsx/network/interfaces" ]; then
  echo "No hi ha cap backup a /gsx/network/ del fitxer interfaces"  >&2
  exit 1
fi

ifdown eth0 --force
ifdown eth1 --force
ifdown eth2 --force
cp -p /gsx/network/resolv.conf /etc/resolv.conf
cp -p /gsx/network/interfaces /etc/network/interfaces
#/etc/init.d/networking restart
ifconfig docker0 up
ifup eth0
ifup eth1
ifup eth2
