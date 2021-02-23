#!/bin/bash

### VARS ###
DOMAIN_NAME=""
SUDO=""

if [[ $EUID -ne 0 ]]; then
   SUDO='sudo'
fi

### General Functions ###

function get_domain_name() {
   read -rp "Enter the domain name to be used:"$'\n' dname
   DOMAIN_NAME=${dname}
}

function transfer_certs() {
   mkdir ${PWD}/certs/${DOMAIN_NAME}
   
   ${SUDO} cp -p /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem ${PWD}/certs/${DOMAIN_NAME}/
   ${SUDO} chown $USER:$USER ${PWD}/certs/${DOMAIN_NAME}/fullchain.pem

   ${SUDO} cp -p /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem ${PWD}/certs/${DOMAIN_NAME}/
   ${SUDO} chown $USER:$USER ${PWD}/certs/${DOMAIN_NAME}/privkey.pem
}

### Files init ###

while [[ -z "${DOMAIN_NAME}" ]]; do
   get_domain_name
done

transfer_certs

ADD_DOMAIN=yes
while [[ "${ADD_DOMAIN}" =~ ^([yY]|[yY][eE][sS])$ ]] ; do
   read -rp "Would you like to add certs for other domains? [y/N] " ADD_DOMAIN
   if [[ "${ADD_DOMAIN}" =~ ^([yY]|[yY][eE][sS])$ ]]; then
      get_domain_name
      transfer_certs
   else
      break
   fi
done

### Run nginx reverse proxy container
docker network create docker_net
#docker-compose up -d

