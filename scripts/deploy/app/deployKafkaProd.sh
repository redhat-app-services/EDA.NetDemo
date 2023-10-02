#!/bin/bash

source ../../common_cfg

# paths
DEMO_PATH=../../demo/kafka

# OCP project name
PROJECT_NAME=kafka-prod

clear
echo "Connecting to OpenShift" 
oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

if isProject ${PROJECT_NAME}; then
  echo "Removing old project"
  oc delete project ${PROJECT_NAME} > /dev/null
fi

oc login ${OC_LOGIN_DEVELOPER} > /dev/null
if ! isProject ${PROJECT_NAME}; then
  echo "Creating a new project for the application"
  oc new-project ${PROJECT_NAME} > /dev/null
fi
echo "Creating secret from certificate file..."
oc create secret generic ca-cert --from-file ${DEMO_PATH}/ca.crt
echo "Creating configmap..."
oc create configmap ${PROJECT_NAME}-conf \
   --from-literal KAFKA_BOOTSTRAP="my-cluster-kafka-bootstrap.amq-streams-kafka.svc.cluster.local:9092" \
   --from-literal KAFKA_SEC_PROTO="Plaintext" \
   --from-literal KAFKA_SSL_CA_LOC="/opt/app-root/secure/ca.crt" \
   --from-literal KAFKA_PROD_CLIENTID="kafka-prodMicroservice" \
   --from-literal KAFKA_TOPIC="my-topic"

echo "Creating new application..."
oc new-app --name=${PROJECT_NAME} 'dotnet:7.0-ubi8~https://github.com/ajhajj/EDA.NetDemo.git#main' --context-dir apps/dotNet/kafkaProducer
echo "Linking configmap to deployment..."
oc set env deployment/${PROJECT_NAME} --from configmap/${PROJECT_NAME}-conf
echo "Linking secret to deployment (as volume mount)..."
oc set volume deployment/${PROJECT_NAME} --add -t secret -m /opt/app-root/secure --name appsec-vol --secret-name ca-cert

#oc logs -f bc/${PROJECT_NAME}
#oc logs -f deployment/${PROJECT_NAME}
echo "Exposing route..."
oc expose svc/${PROJECT_NAME}
oc get routes
