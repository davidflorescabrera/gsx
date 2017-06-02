#! /bin/bash

#Remove previous rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

#Default policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Només accepta peticions de connexions SSH si l'adreça origen és d'una màquina de la subxarxa interna.
iptables -A INPUT -p TCP -s 192.168.2.253 --destination-port 22 -j ACCEPT

#Implementa SNAT amb les connexions originades a la xarxa interna
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.3.0/24 -j MASQUERADE

#Pot accedir als servidors d'actualització de Debian. Mireu el fitxer /etc/apt/sources.list per veure els noms dels servidors i protocols. 
iptables -A OUTPUT -p TCP -d 212.211.132.32,212.211.132.250,195.20.242.89,217.196.149.233,82.194.78.250 --destination-port 80 -j ACCEPT
iptables -A INPUT -p TCP --destination-port 80 -m state --state ESTABLISHED,RELATED -j ACCEPT

#Permet el pas de les consultes DNS dels clients de la xarxa interna sempre i quan el servidor consultat sigui el de la URV (mirar el /etc/resolv.conf del external_router) o els de Google.
iptables -A FORWARD -p UDP -i eth1 -o eth0 -d 10.30.1.2,10.30.1.108,10.45.2.1,8.8.8.8,8.8.4.4 --destination-port 53 -j ACCEPT
iptables -A FORWARD -p UDP -i eht0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

#Permet el pas de les comunicacions ICMP iniciades des de la xarxa interna o del IDS de la DMZ.
iptables -A FORWARD -p ICMP -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -p ICMP -s 192.168.2.253 -j ACCEPT
iptables -A FORWARD -p ICMP -m state --state ESTABLISHED,RELATED -j ACCEPT

#Permet el pas de les comunicacions TCP iniciades des de la xarxa interna.
iptables -A FORWARD -p TCP -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -p TCP -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT