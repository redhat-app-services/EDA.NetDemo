#!/bin/bash
source ../common_cfg

oc login ${OC_LOGIN_KUBEADMIN} > /dev/null
WILDCARD_DOMAIN=$(oc whoami --show-console | sed -e 's|^.*\.apps|apps|')
THREESCALE_URL="https://3scale-admin.${WILDCARD_DOMAIN}"
THREESCALE_USER=$(oc get secret system-seed -o json -n 3scale | jq -r .data.ADMIN_USER | base64 -d)
THREESCALE_PASS=$(oc get secret system-seed -o json -n 3scale | jq -r .data.ADMIN_PASSWORD | base64 -d)
echo " "
echo "========================================================"
echo "Admin Portal URL: ${THREESCALE_URL}"
echo "User: '${THREESCALE_USER}'"
echo "Pass: '${THREESCALE_PASS}'"
echo "========================================================"

THREESCALE_USER=$(oc get secret system-seed -o json -n 3scale | jq -r .data.MASTER_USER | base64 -d)
THREESCALE_PASS=$(oc get secret system-seed -o json -n 3scale | jq -r .data.MASTER_PASSWORD | base64 -d)
THREESCALE_URL="https://master.${WILDCARD_DOMAIN}"
echo " "
echo "========================================================"
echo "Master Admin Portal URL: ${THREESCALE_URL}"
echo "User: '${THREESCALE_USER}'"
echo "Pass: '${THREESCALE_PASS}'"
echo "========================================================"

