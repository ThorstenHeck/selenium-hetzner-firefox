# intermediate cert

root_ca_dir=$HOME/Workspace/initialize-environment/ca/root/ca
cd $root_ca_dir

#### Sign server and client certificates

# create a key

openssl genrsa -out private/server.key.pem 2048
# # chmod 400 private/server.key.pem

# # create certificate signing request server

openssl req -config openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.root_server.local" \
      -key private/server.key.pem \
      -new -sha256 -out csr/server.csr.pem

# # create server certificate

openssl ca -batch -config openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in csr/server.csr.pem \
      -out certs/openvpn_server.cert.pem
# # chmod 444 intermediate/certs/www.example.com.cert.pem

# # verify certificate

openssl verify -CAfile certs/ca.cert.pem \
      certs/openvpn_server.cert.pem


# # create client certificate

openssl genrsa -out private/client.key.pem 2048
# # chmod 400 private/client.key.pem

# # create certificate signing request client

openssl req -config openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.root_client.local" \
      -key private/client.key.pem \
      -new -sha256 -out csr/client.csr.pem


openssl ca -batch -config openssl.cnf \
      -extensions usr_cert -days 375 -notext -md sha256 \
      -in csr/client.csr.pem \
      -out certs/openvpn_client.cert.pem
# chmod 444 intermediate/certs/www.example.com.cert.pem

# # verify certificate

openssl verify -CAfile certs/ca.cert.pem \
      certs/openvpn_client.cert.pem


# # create certificate signing request webgui

openssl genrsa -out private/webgui.key.pem 2048
# # chmod 400 private/webgui.key.pem

openssl req -config openssl.cnf \
      -subj "/C=DE/ST=Germany/L=Berlin/O=vanilla/OU=vanilla/CN=vanilla.root_webgui.local" \
      -key private/webgui.key.pem \
      -new -sha256 -out csr/webgui.csr.pem


openssl ca -batch -config openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in csr/webgui.csr.pem \
      -out certs/openvpn_webgui.cert.pem
# chmod 444 intermediate/certs/www.example.com.cert.pem

# # verify certificate

openssl verify -CAfile certs/ca.cert.pem \
      certs/openvpn_webgui.cert.pem