#!/bin/bash

# One Time SSH-Key Setup Github
# ssh-keygen -t ed25519 -f ~/.ssh/github -C "github" -q -N ""
# Add generated Public Key to Github Account: https://github.com/settings/ssh/new

[[ -z "\${SSH_AGENT_PID}" ]] && eval $(ssh-agent -s) && ssh-add ~/.ssh/github 2>/dev/null || ssh-add ~/.ssh/github 2>/dev/null

mkdir -p ~/Workspace/admin-container/
mkdir -p ~/Workspace/admin-container/.ssh/
mkdir -p ~/Workspace/admin-container/.vault/

git clone git@github.com:ThorstenHeck/admin-container.git ~/Workspace/admin-container/admin-container 2> /dev/null || git -C ~/Workspace/admin-container/admin-container pull --ff-only

cd ~/Workspace/admin-container/admin-container && docker build -q  . -t admin-container 2>/dev/null && cd -

# One Time SSH-Key Setup HCloud

API_TOKEN=$(op get item Hetzner-API-Key --fields password)
SSH_PUB=$(cat ~/Workspace/admin-container/.ssh/ansible_prod.pub)


FILE=~/Workspace/admin-container/.ssh/ansible_prod
if [ -f "$FILE" ]; then
    echo "SSH-Key available - skipping SSH-Key creation"
	SSH_PUB=$(cat ~/Workspace/admin-container/.ssh/ansible_prod.pub)

else 
echo "Creating a new SSH-Key and upload to Hetzner"
ssh-keygen -q -t ed25519 -f ~/Workspace/admin-container/.ssh/ansible_prod -C "ansible" -q -N ''
SSH_PUB=$(cat ~/Workspace/admin-container/.ssh/ansible_prod.pub)
cat <<EOF > data.json
{"labels":{},"name":"ansible","public_key":"$SSH_PUB"}
EOF

# check if ansible key exists, if yes delete and recreate

ssh_key_id=$(curl -H "Authorization: Bearer $API_TOKEN" 'https://api.hetzner.cloud/v1/ssh_keys' | jq '.[][] | select(.name=="ansible") | .id')

if [ -z "$ssh_key_id" ]
then
curl_result=$(curl \
	-X POST \
	-H "Authorization: Bearer $API_TOKEN" \
	-H "Content-Type: application/json" \
	-d @data.json \
	'https://api.hetzner.cloud/v1/ssh_keys')
else

curl_del=$(curl \
	-X DELETE \
	-H "Authorization: Bearer $API_TOKEN" \
	-H "Content-Type: application/json" \
	'https://api.hetzner.cloud/v1/ssh_keys/'$ssh_key_id)

curl_result=$(curl \
	-X POST \
	-H "Authorization: Bearer $API_TOKEN" \
	-H "Content-Type: application/json" \
	-d @data.json \
	'https://api.hetzner.cloud/v1/ssh_keys')
fi



rm data.json

# Write SSH-Key to 1password
title=Ansible-Private-SSH-Key
vault=c4rb2q4ru5aztf6yw3b7yxmupy
if op get item $title --vault $vault >/dev/null 2>&1
then
    op delete item $title --vault $vault
fi
cat ~/Workspace/admin-container/.ssh/ansible_prod | op create document - --title $title --vault $vault --file-name "ansible_prod"

title=Ansible-Public-SSH-Key
vault=c4rb2q4ru5aztf6yw3b7yxmupy
if op get item $title --vault $vault >/dev/null 2>&1
then
    op delete item $title --vault $vault
fi
cat ~/Workspace/admin-container/.ssh/ansible_prod.pub | op create document - --title $title --vault $vault --file-name "ansible_prod.pub"

fi

ANSIBLE_OPNSENSE_HASH=$(op get item "Ansible-User" --fields hash)
ANSIBLE_OPNSENSE_PW=$(op get item "Ansible-User" --fields password)
ROOT_OPNSENSE_HASH=$(op get item "Opnsense-Root-User" --fields hash)
ROOT_OPNSENSE_PW=$(op get item "Opnsense-Root-User" --fields password)

git clone git@github.com:ThorstenHeck/ansible.git ~/Workspace/admin-container/ansible 2> /dev/null || git -C ~/Workspace/admin-container/ansible pull --ff-only 
git clone git@github.com:ThorstenHeck/terraform.git ~/Workspace/admin-container/terraform 2> /dev/null || git -C ~/Workspace/admin-container/terraform pull --ff-only
git clone git@github.com:ThorstenHeck/packer.git ~/Workspace/admin-container/packer 2> /dev/null || git -C ~/Workspace/admin-container/packer pull --ff-only

SSH_PUB=$(echo -n $SSH_PUB | base64 -w 0)

VPN_CA=$(cat ca/root/ca/certs/ca.cert.pem | base64 -w 0)
VPN_CA_KEY=$(cat ca/root/ca/private/ca.key.pem | base64 -w 0)
VPN_CLIENT=$(cat ca/root/ca/certs/openvpn_client.cert.pem | base64 -w 0)
VPN_CLIENT_KEY=$(cat ca/root/ca/private/client.key.pem | base64 -w 0)
VPN_SERVER=$(cat ca/root/ca/certs/openvpn_server.cert.pem | base64 -w 0)
VPN_SERVER_KEY=$(cat ca/root/ca/private/server.key.pem | base64 -w 0)

openvpn --genkey --secret static.key
VPN_STATIC_KEY=$(cat static.key | base64 -w 0)

docker run -it --rm \
-v ~/Workspace/admin-container/ansible:/home/ansible/ansible \
-v ~/Workspace/admin-container/.ssh/:/home/ansible/.ssh \
-v ~/Workspace/admin-container/.vault/:/home/ansible/.vault \
-v ~/Workspace/admin-container/terraform/:/home/ansible/terraform \
-v ~/Workspace/admin-container/packer/:/home/ansible/packer \
-e HCLOUD_TOKEN=$API_TOKEN \
-e TF_VAR_hcloud_token=$API_TOKEN \
-e ANSIBLE_OPNSENSE_PW=$ANSIBLE_OPNSENSE_PW \
-e ROOT_OPNSENSE_PW=$ROOT_OPNSENSE_PW \
-e ANSIBLE_SSH_PUB=$SSH_PUB \
-e VPN_CA=$VPN_CA \
-e VPN_CA_KEY=$VPN_CA_KEY \
-e VPN_CLIENT=$VPN_CLIENT \
-e VPN_CLIENT_KEY=$VPN_CLIENT_KEY \
-e VPN_SERVER=$VPN_SERVER \
-e VPN_SERVER_KEY=$VPN_SERVER_KEY \
-e VPN_STATIC_KEY=$VPN_STATIC_KEY \
--name=admin-container \
admin-container


