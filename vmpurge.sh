#!/bin/bash

#set -x # debug mode
set -e

# =============================================================================================
# global vars

# force english messages
export LANG=C
export LC_ALL=C

declare CONFIG_FILE=template_deploy.conf

if [[ ! -f "${CONFIG_FILE}" ]] ;then
        echo "ERROR: File ${CONFIG_FILE} doesn't exists"
        exit 1
else
        source ${CONFIG_FILE}
fi

qm stop ${TEMPLATE_VMID} || true
sleep 3
qm destroy ${TEMPLATE_VMID} --purge || true
rm /etc/pve/geco-pve/coreos/${TEMPLATE_VMID}* || true
rm ${TEMPLATE_VMID}-*.id || true
sleep 1