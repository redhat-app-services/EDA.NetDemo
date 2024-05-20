#!/bin/bash
source ../../common_cfg

# paths
BASE_PATH=../../..
CRD_PATH=${BASE_PATH}/yaml/apps
EVENT_CONS=${BASE_PATH}/apps/dotNet/eventConsumer/
HOME_PATH=$(pwd)

# OCP project name
PROJECT_NAME=kafka-cons

# Code version
VERSION=1.5

# Rebuild code or just deploy container with this version tag
REBUILD=true

# Image name
IMAGE_NAME="quay.io/${QUAY_USER}/eventconsumer"

if [ "${REBUILD,,}" == "true" ];then
  echo "Removing podman images..."
  podman rmi -f $(podman images | grep ${IMAGE_NAME} | tr -s ' ' | cut -d ' ' -f3)

  cd ${EVENT_CONS}
  echo "Building .net release..."
  dotnet publish -f net7.0 -c Release
  echo "Removing podman images..."
  podman rmi --all
  echo "Building new image"
  podman build --layers=false -t ${IMAGE_NAME}:${VERSION} .
  podman tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
  echo "Pushing image to quay.io..."
  podman login -u="${QUAY_USER}" -p="${QUAY_TOKEN}" quay.io
  podman push ${IMAGE_NAME}:${VERSION}
  podman push ${IMAGE_NAME}
fi

cd ${HOME_PATH}
sed -i -e 's|- image: quay.io/QUAY_USER/eventconsumer|- image: '"${IMAGE_NAME}"'|' \
       -e 's|'"${IMAGE_NAME}"':.*$|'"${IMAGE_NAME}"':'"${VERSION}"'|' ${CRD_PATH}/event-consumer.yml
oc login ${OC_LOGIN_KUBEADMIN} > /dev/null
if isProject ${PROJECT_NAME} ;then
  echo "Deleting project: ${PROJECT_NAME}"
  oc delete project ${PROJECT_NAME}
  sleep 10
fi

echo "Creating project: ${PROJECT_NAME}"
oc new-project ${PROJECT_NAME} > /dev/null
oc apply -f ${CRD_PATH}/event-consumer.yml
oc apply -f ${CRD_PATH}/kafkaSource.yml
