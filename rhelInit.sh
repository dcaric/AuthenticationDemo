#!/bin/bash


echo "alias ll='ls -al'" > .bashrc
source .bashrc


# Red Hat subscription registration and attachment
subscription-manager register --username "dario.caric@gmail.com" --password $RHELPASSWD
subscription-manager attach --auto

# Any additional setup commands can go here
# arm
#subscription-manager repos --enable=codeready-builder-for-rhel-8-aarch64-rpms
#subscription-manager repos --enable=jboss-eap-7-for-rhel-8-aarch64-rpms
#subscription-manager repos --enable=rh-sso-7.6-for-rhel-8-aarch64-rpms
#subscription-manager repos --enable=rhel-8-for-aarch64-appstream-rpms
#subscription-manager repos --enable=rhel-8-for-aarch64-baseos-rpms

#x86
subscription-manager repos --enable=codeready-builder-for-rhel-8-x86_64-rpms
subscription-manager repos --enable=jboss-eap-7-for-rhel-8-x86_64-rpms
subscription-manager repos --enable=rh-sso-7.6-for-rhel-8-x86_64-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms


# log installed repos
subscription-manager repos --list-enabled > enbled.txt

dnf update -y
dnf groupinstall "Development Tools" -y
dnf install jboss-eap7 -y
dnf install rh-sso7 -y
dnf install -y openldap-clients
dnf install procps -y
dnf install net-tools -y
dnf install lsof -y
dnf install iputils -y

# start and enable JBoss EAP
systemctl start eap7-standalone.service
systemctl enable eap7-standalone.service

# start and enable RH-SSO
systemctl start rh-sso7.service
systemctl enable rh-sso7.service

# update ldap
ldapmodify -x -H ldap://host.docker.internal:1389 -D "cn=admin,dc=example,dc=org" -w adminpassword -f add-email.ldif



# Keep the container running
tail -f /dev/null

