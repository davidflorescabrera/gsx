#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 22/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) ./nfs-nis.sh rol pathFitxers pathScripts IPpropia [ipserver]\nOn el rol pot ser client o servidor. Si es client a mes a mes s'ha d'especificar la IP del servidor.
\n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0) descripció
Ubicació de l'script: /gsx\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

if ! (([ "$1" == "client" ] && [ $# -eq 5 ]) || ([ "$1" == "servidor" ] && [ $# -eq 4 ]));then
		echo -e "Ús: ./nfs-nis.sh rol pathFitxers pathScripts IPpropia [ipserver]\nOn el rol pot ser client o servidor. Si es client a mes a mes s'ha d'especificar la IP del servidor."
	exit 1
fi

#Comprovació usuari root
if [ $EUID -ne 0 ]; then
	echo "Aquest script ha de ser executat com a root"
	exit 1
fi

pathFiles="$2"
pathScripts="$3"

case $1 in
servidor)
	# Comprovació que es tenen tots els fitxers
	files=( "nis-sv" "ypserv.securenets" "hosts" "Makefile" "exports")
	paquets=( "nfs-kernel-server" "nis")
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
	# Fi comprovació
	
	#apt-get install nis -> demana domini (L1E.gsx) (es pot modificar (dpkg-reconfigure nis o /etc/defaultdomain)) COM HO FEM?
	cp -p "pathFiles"/nis-sv /etc/default/nis
	cp -p "pathFiles"/ypserv.securenets /etc/ypserv.securenets
	cp -p "pathFiles"/hosts /etc/hosts
	sed -i 's/%%IP%%/'$4'/g' /etc/hosts
	cp -p "pathFiles"/Makefile /var/yp/Makefile #configurem UID min i max segons volguem (per detectar després els clients a connectar)
		#També podrem veure relacionat BD que NIS podrà exportar (ALL= passwd....)
	service ypserv restart
	make -C /var/yp/
	cp -p "pathFiles"/exports /etc/exports #Conté les carpetes a compartir juntament amb amfitrions+modes
	service nfs-kernel-server restart
	;;
client)
	# Comprovació que es tenen tots els fitxers
	files=( "nis-cl", "nsswitch.conf")
	paquets=( "nfs-common" "nis")
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
	# Fi comprovació
	
	echo "ypserver $5" >> /etc/yp.conf
	cp -p "pathFiles"/nsswitch.conf /etc/nsswitch.conf
	echo "+::::::" >> /etc/passwd
	echo "+:::" >> /etc/group
	echo "+::::::::" >> /etc/shadow
	service ypbind restart 
		# ypwich per saber quins clients hi ha disponibles al sv)
		# obrir consola i autentificar-te com a qualsevol usuari
	# mount -t nfs "$5":/dades/origen /dades/desti
	# echo "$5:/dades/origen /dades/desti nfs defaults 0 0" >> /etc/fstab # si no volem temporal s'ha de descomentar aquesta línia
	;;

