#!/bin/bash

### VARS ###
DOMAIN_NAME=""
DOMAIN_ALIASES=""
ALL_DOMAIN_NAMES=""
SITE_FILE=""
CERTS_FILE=""
SUDO=""

if [[ $EUID -ne 0 ]]; then
   SUDO='sudo'
fi

### General Functions ###

function get_domain_name() {
   read -rp "Enter the domain name to be used:"$'\n' dname
   DOMAIN_NAME=${dname}
}

function get_domain_aliases() {
   read -rp "Enter other aliases for the domain (ie: 'www.domain.com sub.domain.com'. Leave empty for none):"$'\n' anames
   DOMAIN_ALIASES=" ${anames}"
   ALL_DOMAIN_NAMES="${DOMAIN_NAME}${DOMAIN_ALIASES}"
}

function transfer_certs() {
   mkdir ${PWD}/certs/${DOMAIN_NAME}
   
   ${SUDO} cp -p /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem ${PWD}/certs/${DOMAIN_NAME}/
   ${SUDO} chown $USER:$USER ${PWD}/certs/${DOMAIN_NAME}/fullchain.pem

   ${SUDO} cp -p /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem ${PWD}/certs/${DOMAIN_NAME}/
   ${SUDO} chown $USER:$USER ${PWD}/certs/${DOMAIN_NAME}/privkey.pem
}

function create_conf_files() {
   if [[ -z "${DOMAIN_NAME}" ]]; then
      # Make a copy of the default.conf file and modify it
      SITE_FILE=sites-available/${DOMAIN_NAME}.conf
      cp default/default.conf ${SITE_FILE}

      sed -i "s/127\.0\.0\.1/${DOMAIN_NAME}/" ${SITE_FILE}
      sed -i "s/exemple\.com/${DOMAIN_NAME}/" ${SITE_FILE}


      # Create the certs conf file, pointing to the location of the certificates.
      CERTS_FILE=conf.d/${DOMAIN_NAME}-certs.conf
      touch ${CERTS_FILE}
      > ${CERTS_FILE}
      echo "ssl_certificate             /etc/ssl/private/${DOMAIN_NAME}/fullchain.pem;" >> ${CERTS_FILE}
      echo "ssl_certificate_key         /etc/ssl/private/${DOMAIN_NAME}/privkey.pem;" >> ${CERTS_FILE}

      sed -i "s#/etc/nginx/conf\.d/certs\.conf#/etc/nginx/${CERTS_FILE}#" ${SITE_FILE}
   else
      echo "Domain name must not be empty."
      return 1
   fi
}

### Main ###

while [[ -z "${DOMAIN_NAME}" ]]; do
   get_domain_name
done

transfer_certs
get_domain_aliases



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
docker-compose up -d

