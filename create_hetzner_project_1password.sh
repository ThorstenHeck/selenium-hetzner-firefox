#!/bin/bash

mkdir -p /tmp/hetzner_api_token
chown 1200:1201 /tmp/hetzner_api_token

docker build -t hetzner_login . 
k
docer run --rm -it \
        -v /tmp/hetzner_api_token:/home/seluser/hetzner_api_token \
        -e USERNAME=$(op get item ogwbjvaifaui7diodogg3gjojm --fields username) \
        -e PASSWORD=$(op get item ogwbjvaifaui7diodogg3gjojm --fields password) \
        -e OWNER_USERNAME=$(op get item ogwbjvaifaui7diodogg3gjojm --fields username) \
        -e OWNER_PASSWORD=$(op get item ogwbjvaifaui7diodogg3gjojm --fields password) \
        -e PROJECT=Vanilla \
        -e PERMISSIONS="Read & Write" \
        -e EMAIL_MEMBER=$(op get item ogwbjvaifaui7diodogg3gjojm --fields username) \
        -e MEMBER_ROLE=admin \
        hetzner_login python3 hetzner_login.py


password=$(cat /home/$(id -u -n)/Workspace/initialize-environment/hetzner_api_token/HETZNER_API_TOKEN)
title=Hetzner-API-Key
vault=c4rb2q4ru5aztf6yw3b7yxmupy

tmp=$(mktemp)
op get template Password > password.json
jq --arg pw "$password" '.password = $pw' password.json > "$tmp" && mv "$tmp" password.json
op create item --template=password.json Password --title $title --vault $vault
rm password.json

rm -rf /tmp/hetzner_api_token