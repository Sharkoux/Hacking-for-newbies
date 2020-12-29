#!/bin/bash

#Reinitialise les règles
iptables -t filter -F
iptables -t filter -X

#Nous indiquons de ne pas fermer les connexions déjà établies:
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#loopback
#iptables -t filter -A INPUT -i lo -j ACCEPT
#iptables -t filter -A OUTPUT -o lo -j ACCEPT

#Autorise les requetes ICMP ping
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT

#Autorise le ssh
iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 22 -j ACCEPT

#DNS
iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT

#HTTP
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A  INPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 8443 -j ACCEPT

#NTP
#iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT

#FTP
#modprobe ip_conntrack_ftp
#iptables -t filter -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
#iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT
#iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#POP3
#iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
#iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT

#MAIL SMTP
#iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
#iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT

#IMAP
#iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT
#iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT


#Bloque par défaut tout le trafic
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#Verification des règles
iptables -L
