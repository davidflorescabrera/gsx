#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 22/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) lp.sh virtualImpre -d\n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Crea una impresora per convertir els fitxers a PDF i guardar-los sota el directori /mnt/mem/USER/DocsPDF \n
Ubicació de l'script: /GSX\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

#Comprovació número de parámetres
if [ $# -ne 2 ]; then
	echo "Us: lp.sh -d virtualImpre "
     	exit 1
fi

#Abans d'haver realitzat això hauriem de tenir ja el login: passwd a /usr/local/secret
if [ $2=="virtualImpre" ]; then
	if [ "$1" == "-d" ]; then
		#Llegim contrasenya
		read -sp "Contrasenya:" password
		#Comprovem la pass
		htpasswd -vb /usr/local/secret ${USER} $password
		#En cas erroni, missatge informant
		if [ $? -ne 0 ]; then
			echo -e "Contrasenya incorrecta"
			exit 1
		fi
	fi
fi
#Possem els paràmetres per substituir el lp predefinit
/usr/bin/lp "$@"
exit 0
