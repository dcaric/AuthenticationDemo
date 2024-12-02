#!/bin/bash

mkdir -p /var/lib/ipa /var/lib/ipa-client /etc/ipa /var/log/dirsrv
chmod -R 755 /var/lib/ipa /var/lib/ipa-client /etc/ipa /var/log/dirsrv

mkdir -p /data/etc/ipa /data/var/lib/ipa /data/var/lib/ipa-client
chmod -R 755 /data/etc /data/var/lib

mkdir -p /data/var/lib/ipa/sysrestore
touch /data/var/lib/ipa/sysrestore/sysrestore.state
chmod -R 755 /data/var/lib/ipa


echo "ipa.example.com" > /etc/hostname
echo "127.0.0.1 ipa.example.com ipa" >> /etc/hosts
hostname ipa.example.com

echo "172.18.0.3 ipa.example.com ipa" >> /etc/hosts



# Since hostnamectl is failing, you can create a temporary workaround by overriding it.
# Replace the hostnamectl command with a script that does nothing:
mv /bin/hostnamectl /bin/hostnamectl.bak

# Create a dummy hostnamectl script:
echo -e '#!/bin/bash\nexit 0' > /bin/hostnamectl
chmod +x /bin/hostnamectl


# download certificate
mkdir -p /data/etc/pki/tls/certs
chmod 755 /data/etc/pki/tls/certs
curl -k -o /data/etc/pki/tls/certs/ca-bundle.crt https://curl.se/ca/cacert.pem
yum install -y ca-certificates
yum install -y softhsm

mkdir -p /data/etc/pkcs11/modules
chmod 755 /data/etc/pkcs11/modules
echo "module: /usr/lib64/pkcs11/libsofthsm2.so" > /data/etc/pkcs11/modules/softhsm2.module


mkdir -p /data/etc/dirsrv/slapd-EXAMPLE-COM
chmod 755 /data/etc/dirsrv/slapd-EXAMPLE-COM

# Initialize FreeIPA and log output to a temporary log file
ipa-server-install --unattended \
    --realm=EXAMPLE.COM \
    --domain=example.com \
    --ds-password=admin1234 \
    --admin-password=admin1234 \
    --hostname=ipa.example.com \
    --setup-dns \
    --forwarder=8.8.8.8 \
    --debug \
    --skip-mem-check \
    --no-ntp \
    > /tmp/ipa-install.log 2>&1

# Check if installation failed
if [ $? -ne 0 ]; then
    echo "FreeIPA installation failed. See /tmp/ipa-install.log for details."
    cat /tmp/ipa-install.log
    exit 1
fi

# Keep the container running
tail -f /tmp/ipa-install.log

