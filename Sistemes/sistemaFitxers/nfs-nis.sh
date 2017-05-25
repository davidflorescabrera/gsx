#! /bin/bash
# Author: Joan Boronat, David Flores and Miquel Sabate
# Version: 1.0
# Date: 22/05/2017
# Description:
usage="$(basename "$0") -- "
usage="\n$(tput bold)FORMA D'ÚS:  $(tput sgr0) ./nfs-nis.sh rol pathFitxers IPpropia [ipserver]\nOn el rol pot ser client o servidor. Si es client a mes a mes s'ha d'especificar la IP del servidor.
\n\n$(tput bold)DESCRIPCIÓ:$(tput sgr0) L'script en mode servidor crea un servidor NIS i NFS. En mode client crea un link (amb mount) entre la carpeta /home/remots del servidor i una carpeta (que crea si no existeix) anomenada nfs-nisClientFiles a /home.
Ubicació de l'script: /gsx\n
Permisos: 744 (propietari pot llegir, escriure i executar l'script. Grup i altres només poden llegir-lo.)"

#Comanda help
if [ "$1" == "-h" ] || [ "$1" == "help" ]; then
	echo -e "$usage"
	exit 0
fi

if ! (([ "$1" == "client" ] && [ $# -eq 4 ]) || ([ "$1" == "servidor" ] && [ $# -eq 3 ]));then
		echo -e "Ús: ./nfs-nis.sh rol pathFitxers pathScripts IPpropia [ipserver]\nOn el rol pot ser client o servidor. Si es client a mes a mes s'ha d'especificar la IP del servidor."
	exit 1
fi

#Comprovació usuari root
if [ $EUID -ne 0 ]; then
	echo "Aquest script ha de ser executat com a root"
	exit 1
fi

pathFiles="$2"

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

	# Creació usuaris (en cas de confirmar)
	read -p "Vols crear els 3 usuaris remots? [s/n]" </dev/tty
	if [[ $REPLY =~ [sSyY] ]]; then
		if [ ! -d /home/remots ]; then
			mkdir /home/remots
		fi
		echo -e "[!] Es crearan 3 usuaris (usuari1, usuari2 i usuari3 amb els directoris a /home/remots, UID=200X (on X és 1, 2 o 3) i pass=login)\n"
		cryptedpass=$(openssl passwd -crypt -salt u usuari1)
		useradd -m -d /home/remots/usuari1 -p "$cryptedpass" -u 2001 usuari1
		cryptedpass=$(openssl passwd -crypt -salt u usuari2)
		useradd -m -d /home/remots/usuari2 -p "$cryptedpass" -u 2002 usuari2
		cryptedpass=$(openssl passwd -crypt -salt u usuari3)
		useradd -m -d /home/remots/usuari3 -p "$cryptedpass" -u 2003 usuari3
	fi
	
	cp -p "$pathFiles"/nis-sv /etc/default/nis
	cp -p "$pathFiles"/ypserv.securenets /etc/ypserv.securenets
	cp -p "$pathFiles"/hosts /etc/hosts
	sed -i 's/%%IP%%/'$3'/g' /etc/hosts
	cp -p "$pathFiles"/Makefile /var/yp/Makefile
	service ypserv restart
	make -C /var/yp/
	cp -p "$pathFiles"/exports /etc/exports #Conté les carpetes a compartir juntament amb amfitrions+modes
	service nfs-kernel-server restart
	;;
client)
	# Comprovació que es tenen tots els fitxers
	files=( "nis-cl" "nsswitch.conf")
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
	cp -p "$pathFiles"/nis-sv /etc/default/nis
	echo "ypserver $4" >> /etc/yp.conf
	cp -p "$pathFiles"/nsswitch.conf /etc/nsswitch.conf
	echo "+::::::" >> /etc/passwd
	echo "+:::" >> /etc/group
	echo "+::::::::" >> /etc/shadow
	service ypbind restart 
	if [ ! -d /home/nfs-nisClientFiles ]; then
			mkdir /home/nfs-nisClientFiles
		fi
	mount -t nfs "$4":/home/remots /home/nfs-nisClientFiles
	echo "$4:/home/remots /home/nfs-nisClientFiles nfs defaults 0 0" >> /etc/fstab
esac
