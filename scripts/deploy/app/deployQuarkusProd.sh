#!/bin/bash
source ../../common_cfg

# paths
BASE_PATH=../../..
DEMO_PATH=../../demo/kafka
CRD_PATH=${BASE_PATH}/yaml/apps
QUARK_PROD=../../../apps/quarkus/kafkaProducer
HOME_PATH=$(pwd)

# OCP project name
PROJECT_NAME=quarkus-producer

# Code version
VERSION=1.8

# Rebuild code or just deploy container with this version tag
REBUILD=true

# Image name
IMAGE_NAME="quay.io/${QUAY_USER}/quarkus-prod"

if [ "${REBUILD,,}" == "true" ];then
  echo "Removing podman images..."
  podman rmi -f $(podman images | grep ${IMAGE_NAME} | tr -s ' ' | cut -d ' ' -f3)

  cd ${QUARK_PROD}
  echo "Building quarkus release..."
  export JAVA_HOME=/usr/lib/jvm/jre-17-openjdk-17.0.10.0.7-3.fc40.x86_64
  ./mvnw -DskipTests clean compile package
 
#  echo "Removing podman images..."
#  podman rmi --all

  echo "Building new image"
  cp src/main/docker/Dockerfile.jvm Dockerfile
  podman build --layers=false -t ${IMAGE_NAME}:${VERSION} .
  podman tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

  echo "Pushing image to quay.io..."
  podman login -u="${QUAY_USER}" -p="${QUAY_TOKEN}" quay.io
  podman push ${IMAGE_NAME}:${VERSION}
  podman push ${IMAGE_NAME}
  rm -f Dockerfile
fi

cd ${HOME_PATH}
sed -i -e 's|- image: quay.io/QUAY_USER/quarkus-prod|- image: '"${IMAGE_NAME}"'|' \
       -e 's|'"${IMAGE_NAME}"':.*$|'"${IMAGE_NAME}"':'"${VERSION}"'|' ${CRD_PATH}/quarkus-prod.yml
oc login ${OC_LOGIN_KUBEADMIN} > /dev/null
if isProject ${PROJECT_NAME} ;then
  echo "Deleting project: ${PROJECT_NAME}"
  oc delete project ${PROJECT_NAME}
  sleep 10
fi

echo "Creating project: ${PROJECT_NAME}"
oc new-project ${PROJECT_NAME} > /dev/null

echo "Creating secret from certificate file..."
oc create secret generic ca-cert --from-file ${DEMO_PATH}/ca.crt
echo "Creating configmap..."
oc create configmap ${PROJECT_NAME}-conf \
   --from-literal KAFKA_BOOTSTRAP="my-cluster-kafka-bootstrap.amq-streams-kafka.svc.cluster.local:9092" \
   --from-literal KAFKA_SEC_PROTO="Plaintext" \
   --from-literal KAFKA_SSL_CA_LOC="/opt/app-root/secure/ca.crt" \
   --from-literal KAFKA_PROD_CLIENTID="kafka-prodMicroservice" \
   --from-literal KAFKA_TOPIC="my-topic"

oc apply -f ${CRD_PATH}/quarkus-prod.yml
echo "Linking configmap to deployment..."
oc set env deployment/${PROJECT_NAME} --from configmap/${PROJECT_NAME}-conf
echo "Linking secret to deployment (as volume mount)..."
oc set volume deployment/${PROJECT_NAME} --add -t secret -m /opt/app-root/secure --name appsec-vol --secret-name ca-cert

echo "Exposing route..."
oc expose svc/${PROJECT_NAME}
oc get routes
