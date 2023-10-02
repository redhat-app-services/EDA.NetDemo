#!/bin/bash

source ../../common_cfg

# paths
CRD_PATH=../../../yaml/mssql

# OCP project name
PROJECT_NAME=mssql

if [ ${#DEPLOY_EVERYTHING} -eq 0 ]; then
  clear
fi

failChk oc login ${OC_LOGIN_DEVELOPER} > /dev/null
if ! isProject ${PROJECT_NAME}; then
  failChk oc new-project ${PROJECT_NAME} > /dev/null
fi

failChk oc create secret generic mssql --from-literal=SA_PASSWORD="redHat2023!"
failChk oc create serviceaccount sqlserver-sa -n mssql
failChk oc login ${OC_LOGIN_KUBEADMIN} > /dev/null
failChk oc adm policy add-scc-to-user anyuid -z sqlserver-sa -n mssql
failChk oc login ${OC_LOGIN_DEVELOPER} > /dev/null
failChk oc apply -f ./${CRD_PATH}/pvc.yaml
failChk oc apply -f ./${CRD_PATH}/Deployment.yaml
NODEPORT=$(oc get svc/sqlserver-external -o yaml | grep "nodePort" | sed -e 's/^.*nodePort: //')
echo "External DB clients can connect on apps-crc.testing:${NODEPORT}"
