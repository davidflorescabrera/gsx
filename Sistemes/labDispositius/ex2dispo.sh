#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 2.0
# Date: 22/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) ex2dispo.sh \n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Crea una impresora per convertir els fitxers a PDF i guardar-los sota el directori /mnt/mem/USER/DocsPDF \n
Ubicació de l'script: /GSX\n
Permisos: 755 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

#Comprovació número de parámetres
if [ $# -ne 0 ]; then
	echo "Us: ex2dispo.sh"
     	exit 1
fi

#Comprovació usuari root
if [ $EUID -ne 0 ]; then
	echo "Aquest script ha de ser executat com a root"
	exit 1
fi

#instal·lem el cups-pdf per si no el teniem
apt-get install cups-pdf 

#Comprovem que els directoris necessàris existeixen i sinó els creem
if [ ! -e /mnt/mem ]; then
	mkdir /mnt/mem
fi


#Creem la impresora virtual 
lpadmin -p virtualImpre -E -v /mnt/mem/${USER}/DocsPDF

#Fem una impressio de prova per veure que funciona
lp /usr/share/cups/data/testprint

echo -e "Hem imprès un doc de prova per comprovar el funcionament."

