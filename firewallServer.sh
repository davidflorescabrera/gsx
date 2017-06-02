#!/bin/bash

#Remove previous rules
iptables -F
iptables -X

#Default policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Accepta connexions SSH només si provenen del Internal_Router o del IDS de la DMZ.
iptables -A INPUT -p TCP -s 192.168.2.2,192.168.2.253 --destination-port 22 -j ACCEPT

#Accepta connexions HTTPS de qualsevol màquina.
iptables -A INPUT -p TCP --destination-port 443 -j ACCEPT
iptables -A INPUT -p TCP -s 192.168.2.2,192.168.2.253 --destination-port 80 -j ACCEPT
iptables -A OUTPUT -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT

#Pot accedir als servidors d'actualització de Debian. Mireu el fitxer /etc/apt/sources.list per veure els noms dels servidors i protocols. 
iptables -A OUTPUT -p TCP -d 82.194.78.250,212.211.132.32,212.211.132.250,195.20.242.89,217.196.149.233 --destination-port 80 -j ACCEPT

iptables -A INPUT -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT

#Només pot fer consultes als DNS de la URV o als de Google.
iptables -A OUTPUT -p UDP -d 10.30.1.2,10.30.1.108,10.45.2.1,8.8.8.8,8.8.4.4 --destination-port 53 -j ACCEPT
iptables -A INPUT -p UDP -m state --state ESTABLISHED,RELATED -j ACCEPT

#Permet accedir a la BD MySQL si la connexió prové d'una màquina de la xarxa interna o del Internal_Router.
iptables -A INPUT -p TCP -s 192.168.2.2 --destination-port 3306 -j ACCEPT