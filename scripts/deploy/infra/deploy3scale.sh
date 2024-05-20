#!/bin/bash

if [ ${#DEPLOY_EVERYTHING} -eq 0 ]; then
  clear
  source ../../common_cfg
fi

# paths
BASE_PATH=../../../yaml/3Scale

# Operator name
CLUSTER_OP_NAME="Red Hat Integration - 3scale"

# Operator namespace
CLUSTER_OP_NS=3scale
APICAST_OP_NS=apicast-op

# Project name
PROJECT_NAME=${CLUSTER_OP_NS}

failChk oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

# get the base wildcard domain
WILDCARD_DOMAIN=$(oc whoami --show-console | sed -e 's|^.*\.apps|apps|')

# making file changes a few steps early to avoid write flush issues
rm -f ${BASE_PATH}/api-man.yaml
cp ${BASE_PATH}/template/api-man.yaml ${BASE_PATH}/api-man.yaml
sed -i -e 's/^  wildcardDomain: .*/  wildcardDomain: '"${WILDCARD_DOMAIN}"'/' ${BASE_PATH}/api-man.yaml

if ! isProject ${PROJECT_NAME}; then
  failChk oc new-project ${PROJECT_NAME} > /dev/null
fi

# Install pull secret
failChk oc apply -f ${BASE_PATH}/threescale-registry-auth.yaml
failChk oc secrets link default threescale-registry-auth --for=pull
failChk oc secrets link builder threescale-registry-auth

echo "Installing operator for '${CLUSTER_OP_NAME}'..."
failChk oc apply -f ${BASE_PATH}/3scale-sub.yaml > /dev/null

# Wait for deployment success
echo "Waiting for '${CLUSTER_OP_NAME}' to be ready..."
STATUS="pending"
while [ "${STATUS,,}" != "succeeded" ]; do
  sleep 1
  STATUS=$(oc get csv -n ${CLUSTER_OP_NS} 2>/dev/null | grep "${CLUSTER_OP_NAME}" | sed -e 's/^.* //' | tr -s ' ')
done
echo "'${CLUSTER_OP_NAME}' is ready"

echo "Installing APIcast Operator..."
#if ! isProject ${APICAST_OP_NS}; then
#  oc new-project ${APICAST_OP_NS} > /dev/null
#fi
failChk oc apply -f ${BASE_PATH}/apicast_sub.yaml > /dev/null

# Wait for deployment success
#echo "Waiting for '${CLUSTER_OP_NAME}' to be ready..."
#STATUS="pending"
#while [ "${STATUS,,}" != "succeeded" ]; do
#  sleep 1
#  STATUS=$(oc get csv -n ${CLUSTER_OP_NS} 2>/dev/null | grep "${CLUSTER_OP_NAME}" | sed -e 's/^.* //' | tr -s ' ')
#done
#echo "'${CLUSTER_OP_NAME}' is ready"

echo "Installing APIManager..."
failChk oc project ${PROJECT_NAME} > /dev/null
failChk oc apply -f ${BASE_PATH}/api-man.yaml > /dev/null

# Wait for pod deployments to complete
echo "Waiting on APIManager availability..."
STATUS="1"
while [ "${STATUS}" != "0" ]; do
  sleep 5
  STATUS=$(oc get APIManager -o yaml | grep '      status: "True')
  STATUS="$?"
done
echo "APIManager is now available"

THREESCALE_URL="https://3scale-admin.${WILDCARD_DOMAIN}"
THREESCALE_USER=$(oc get secret system-seed -o json | jq -r .data.ADMIN_USER | base64 -d)
THREESCALE_PASS=$(oc get secret system-seed -o json | jq -r .data.ADMIN_PASSWORD | base64 -d)
echo " "
echo "========================================================"
echo "Admin Portal URL: ${THREESCALE_URL}"
echo "User: '${THREESCALE_USER}'"
echo "Pass: '${THREESCALE_PASS}'"
echo "========================================================"

THREESCALE_USER=$(oc get secret system-seed -o json | jq -r .data.MASTER_USER | base64 -d)
THREESCALE_PASS=$(oc get secret system-seed -o json | jq -r .data.MASTER_PASSWORD | base64 -d)
THREESCALE_URL="https://master.${WILDCARD_DOMAIN}"
echo " "
echo "========================================================"
echo "Master Admin Portal URL: ${THREESCALE_URL}"
echo "User: '${THREESCALE_USER}'"
echo "Pass: '${THREESCALE_PASS}'"
echo "========================================================"

