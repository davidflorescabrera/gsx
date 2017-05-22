#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 22/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) ex2dispo.sh \n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Crea una impresora per convertir els fitxers a PDF i guardar-los sota el directori /mnt/mem/DocsPDF/${USER} \n
Ubicació de l'script: /GSX\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

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

#primer comprovar que el cups-pdf està instal·lat, sino instalar-lo
# impressio de prova i funciona: lp /usr/share/cups/data/testprint FUNCIONA!
#el cups-pdf te un fitxer de configuració al /etc/cups/cups-pdf.conf (configurar-lo com ens demana) i copiarlo a aquest dir, i per 
#defecte els fitxers s'escriuen al /var/spool/cups-pdf/${USER} redirigir-los al que ens interesa
#crear la impresora amb lpadmin -p virtualImpre -E -v /mnt/mem/DocsPDF/${USER}
