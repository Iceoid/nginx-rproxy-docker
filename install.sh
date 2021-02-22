#!/bin/bash

### VARS ###
DOMAIN_NAME=mindlab.dev
SUDO=''

if [[ $EUID -ne 0 ]]; then
   SUDO='sudo'
fi

### Install Docker ###
${SUDO} apt update
${SUDO} apt install docker.io -y;${SUDO} apt install docker-compose -y

### TODO: check if user is in the docker group already. if not, user needs to logout and log back in for the next line to take effect.
${SUDO} usermod -aG docker $USER

### Files init ###
${SUDO} ln -s /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem ${PWD}/certs/
${SUDO} ln -s /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem ${PWD}/certs/
${SUDO} chmod -R 600 ${PWD}/certs

### Run nginx reverse proxy container
docker-compose up -d

