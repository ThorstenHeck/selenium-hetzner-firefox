#!/bin/bash
docker build -t hetzner_login . 

docker run --rm -it \
        -e USERNAME=hetznerlogin \
        -e PASSWORD=secret \
        -e PROJECT=Vanilla \
        -e PERMISSIONS="Read & Write" \
        -e EMAIL_MEMBER=member@mail.com \
        -e MEMBER_ROLE=admin \
        hetzner_login -c