#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 09/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) ./guarda_web.sh\nGuarda els fitxers necessaris per posar en marxa el servidor web en un fitxer anomenat websites.tgz. Aquest fitxer .tgz es guarda a la carpeta /gsx\n
Ubicació de l'script: /gsx\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

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

tar cvfz /gsx/websites.tgz /var/www/html/ /var/www/taller/var/www/tenda/ /etc/apache2/sites-available/taller.conf /etc/apache2/sites-available/tenda.conf
