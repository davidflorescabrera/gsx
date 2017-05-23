#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 22/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) lp.sh -d virtualImpre path\n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0)
Crea una impresora per convertir els fitxers a PDF i guardar-los sota el directori /mnt/mem/USER/DocsPDF \n
Ubicació de l'script: /GSX\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

#Comprovació número de parámetres
if [ $# -lt 1 ]; then
	echo "Us: lp.sh -d virtualImpre path_fitxer"
     	exit 1
fi

#Abans d'haver realitzat això hauriem de tenir ja el login: passwd a /usr/local/secret
if [ "$2" == "virtualImpre" ]; then
	if [ "$1" == "-d" ]; then
		#Llegim contrasenya
		read -sp "Contrasenya per l'usuari '${USER}':" password
		#Comprovem la pass
		htpasswd -vb /usr/local/secret/htpasswd ${USER} $password
		#En cas erroni, missatge informant
		if [ $? -ne 0 ]; then
			echo -e "Contrasenya incorrecta"
			exit 1
		fi
		#Que faci lo de la comanda lp
		/usr/bin/lp "$@"
	fi
else
	/usr/bin/lp "$@"
fi
exit 0
