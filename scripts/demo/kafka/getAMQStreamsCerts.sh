!/bin/bash
source ../../common_cfg

# paths
BASE_PATH=.

# OCP project name
PROJECT_NAME=amq-streams-kafka

# Cluster name
CLUSTER_NAME=my-cluster

clear

oc login ${OC_LOGIN_DEVELOPER} > /dev/null
if ! isProject "${PROJECT_NAME}"
then
  oc project ${PROJECT_NAME} > /dev/null
fi

rm -f ${BASE_PATH}/ca.crt
rm -f ${BASE_PATH}/client.truststore.jks

# Get External route to Bootstrap server
oc get routes ${CLUSTER_NAME}-kafka-listener1-bootstrap -o=jsonpath='{.status.ingress[0].host}{"\n"}'

# Get public certificate
oc extract secret/${CLUSTER_NAME}-cluster-ca-cert --keys=ca.crt --to=- > ${BASE_PATH}/ca.crt

# Create a local truststore (java only)
keytool -keystore ${BASE_PATH}/client.truststore.jks -alias CARoot -importcert -file ${BASE_PATH}/ca.crt -storepass redhat -noprompt

