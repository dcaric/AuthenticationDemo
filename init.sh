#!/bin/bash
mkdir -p /etc/samba
touch /etc/samba/tls.dpkg-new
chmod 777 /etc/samba/tls.dpkg-new
apt update
DEBIAN_FRONTEND=noninteractive apt install -y samba smbldap-tools net-tools iputils-ping
smbd --foreground

