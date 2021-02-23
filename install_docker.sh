#!/bin/bash
SUDO=''

if [[ $EUID -ne 0 ]]; then
   SUDO='sudo'
fi

### Install Docker ###
${SUDO} apt update
${SUDO} apt install docker.io docker-compose -y

### TODO: check if user is in the docker group already. if not, user needs to logout and log back in for the next line to take effect.
${SUDO} usermod -aG docker $USER
exit
