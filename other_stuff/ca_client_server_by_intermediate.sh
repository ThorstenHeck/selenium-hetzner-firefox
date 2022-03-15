# intermediate cert

root_ca_dir=$HOME/Workspace/initialize-environment/ca/root/ca
intermediate_ca_dir=$HOME/Workspace/initialize-environment/ca/root/ca/intermediate
cd $root_ca_dir

#### Sign server and client certificates

# create a key

openssl genrsa -out intermediate/private/csr.key.pem 2048
# # chmod 400 intermediate/private/csr.key.pem

# # create certificate signing request server

openssl req -config intermediate/openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.intermediate_server.local" \
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

# # create certificate signing request client

openssl req -config intermediate/openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.intermediate_client.local" \
      -key intermediate/private/csr.key.pem \
      -new -sha256 -out intermediate/csr/csr.csr.pem


openssl ca -batch -config intermediate/openssl.cnf \
      -extensions usr_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/csr.csr.pem \
      -out intermediate/certs/openvpn_client.cert.pem
# chmod 444 intermediate/certs/www.example.com.cert.pem

# # verify certificate

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/openvpn_client.cert.pem


# # create certificate signing request webgui

openssl req -config intermediate/openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.intermediate_webgui.local" \
      -key intermediate/private/csr.key.pem \
      -new -sha256 -out intermediate/csr/csr.csr.pem


openssl ca -batch -config intermediate/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/csr.csr.pem \
      -out intermediate/certs/openvpn_webgui.cert.pem
# chmod 444 intermediate/certs/www.example.com.cert.pem

# # verify certificate

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/openvpn_webgui.cert.pem