#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 22/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) ex1dispo.sh \n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Aquest script crea un sistema de fitxers del tipus ext2 on la part reservada per root es del 10% i s'assigna tot l'arbre de directoris que està sota /home. A la partició arrel només es deixarà l'usuari root \n
Ubicació de l'script: /GSX\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"
size="$1"
#Comprovació número de parámetres
if [ $# -ne 1 ]; then
	echo "Us: ex1dispo.sh disk_size"
     	exit 1
fi

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

#Creem el directori on anirà el nostre disc
if [ ! -e /mnt/mem ]; then
	mkdir /mnt/mem
fi
#Montem el disc virtual tmpfs de 100 MB (s'especifica per paràmetre el tamany del disc a crear)
mount -t tmpfs -o size="$size"m tmpfs /mnt/mem

echo -e "S'ha creat un disc virtual a memòria de $size MB"