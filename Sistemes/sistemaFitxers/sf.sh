#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 4.0
# Date: 17/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) sf.sh \n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Aquest script crea un sistema de fitxers del tipus ext2 on la part reservada per root es del 10% i s'assigna tot l'arbre de directoris que està sota /home. A la partició arrel només es deixarà l'usuari root \n
Ubicació de l'script: /GSX\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comprovació número de parámetres
if [ $# -ne 1 ]; then
	echo "Us: sf.sh"
     	exit 1
fi

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

swapoff /dev/sda6
mkfs.ext2 -m 10 /dev/sda6
mount /dev/sda6 /mnt
cp -a /home /mnt

for user in $(ls /./home)
do
	mv /mnt/home/"$user" /mnt/"$user"
done

rmdir /mnt/home
umount /mnt
mount /dev/sda6 /home