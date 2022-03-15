# intermediate cert

root_ca_dir=$HOME/Workspace/initialize-environment/ca/root/ca
intermediate_ca_dir=$HOME/Workspace/initialize-environment/ca/root/ca/intermediate
mkdir -p $intermediate_ca_dir
cd $intermediate_ca_dir

mkdir certs crl csr newcerts private
#chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# get fresh config file

wget -O openssl.cnf https://jamielinux.com/docs/openssl-certificate-authority/_downloads/intermediate-config.txt

# adjust config file

sed -i "s|/root/ca/intermediate|$intermediate_ca_dir|g" openssl.cnf
sed -i "s|GB|DE|g" openssl.cnf
sed -i "s|England|Germany|g" openssl.cnf
sed -i "s|Alice Ltd|vanilla|g" openssl.cnf
sed -i "s|organizationalUnitName_default  =|organizationalUnitName_default  = vanilla|g" openssl.cnf
sed -i "s|emailAddress_default            =|emailAddress_default            = vpn@vanilla.org|g" openssl.cnf
sed -i "s|localityName_default            =|localityName_default            = Berlin|g" openssl.cnf

# create root key with passphrase
cd $root_ca_dir
# openssl genrsa -aes256 -out intermediate/private/intermediate.key.pem 4096

# create root key without passphrase
openssl genrsa -out intermediate/private/intermediate.key.pem 4096

#chmod 400 intermediate/private/intermediate.key.pem

# create CSR interm

openssl req -config intermediate/openssl.cnf -new -sha256 \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.csr_interm.local" \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem

# create intermediate cert 

openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

# chmod 444 intermediate/certs/intermediate.cert.pem

# verify intermediate cert against root cert

openssl verify -CAfile certs/ca.cert.pem \
      intermediate/certs/intermediate.cert.pem

# create the certificate chain file

cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
# chmod 444 intermediate/certs/ca-chain.cert.pem

#### Sign server and client certificates

# create a key

openssl genrsa -out intermediate/private/csr.key.pem 2048
# # chmod 400 intermediate/private/csr.key.pem


# # create certificate signing request server

openssl req -config intermediate/openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.csr_server.local" \
      -key intermediate/private/csr.key.pem \
      -new -sha256 -out intermediate/csr/csr.csr.pem

# # create server certificate

openssl ca -batch -config intermediate/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/csr.csr.pem \
      -out intermediate/certs/openvpn_server.cert.pem
# # chmod 444 intermediate/certs/www.example.com.cert.pem

# # verify certificate

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/openvpn_server.cert.pem


# # create client certificate

# # create certificate signing request server

openssl req -config intermediate/openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.csr_client.local" \
      -key intermediate/private/csr.key.pem \
      -new -sha256 -out intermediate/csr/csr.csr.pem


openssl ca -batch -config intermediate/openssl.cnf \
      -extensions usr_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/csr.csr.pem \
      -out intermediate/certs/openvpn_client.cert.pem
# chmod 444 intermediate/certs/www.example.com.cert.pem

# # verify certificate

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/openvpn_server.cert.pem