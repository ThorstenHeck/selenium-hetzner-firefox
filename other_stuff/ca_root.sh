# root cert

root_ca_dir=$HOME/Workspace/initialize-environment/ca/root/ca
mkdir -p $root_ca_dir
cd $root_ca_dir

mkdir certs crl newcerts csr private
#chmod 700 private
touch index.txt
echo 1000 > serial

# get fresh config file
wget -O openssl.cnf https://jamielinux.com/docs/openssl-certificate-authority/_downloads/root-config.txt

# adjust config file
sed -i "s|/root/ca|$root_ca_dir|g" openssl.cnf

sed -i "s|GB|DE|g" openssl.cnf
sed -i "s|England|Germany|g" openssl.cnf
sed -i "s|Alice Ltd|vanilla|g" openssl.cnf
sed -i "s|organizationalUnitName_default  =|organizationalUnitName_default  = vanilla|g" openssl.cnf
sed -i "s|emailAddress_default            =|emailAddress_default            = vpn@vanilla.org|g" openssl.cnf
sed -i "s|localityName_default            =|localityName_default            = Berlin|g" openssl.cnf


# create root key with passphrase
# openssl genrsa -aes256 -out private/ca.key.pem 4096

# create root key without passphrase
openssl genrsa -out private/ca.key.pem 4096

#chmod 400 private/ca.key.pem

# create root certificate

openssl req -config openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.local/emailAddress=vanilla@opnsense.local" \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

# verify

# openssl x509 -noout -text -in certs/ca.cert.pem
