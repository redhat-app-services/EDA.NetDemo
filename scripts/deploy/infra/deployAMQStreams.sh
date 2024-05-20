#!/bin/bash

if [ ${#DEPLOY_EVERYTHING} -eq 0 ]; then
  clear
  source ../../common_cfg
fi

# paths
BASE_PATH=../../../yaml/kafka
DEMO_PATH=../../demo/kafka
CLUSTER_OP_PATH=${BASE_PATH}/install/cluster-operator
KAFKA_CRD_PATH=${BASE_PATH}/examples/kafka

# kafka persistence
KAFKA_PERSISTENCE=kafka-ephemeral.yaml
#KAFKA_PERSISTENCE=kafka-persistent.yaml

# OCP project name
PROJECT_NAME=amq-streams-kafka

# Cluster operator namespace
CLUSTER_OP_NS=${PROJECT_NAME}
CLUSTER_NAME=my-cluster
LISTENER_NAME=listener1

USE_OPERATOR_HUB=true

failChk oc login ${OC_LOGIN_DEVELOPER} > /dev/null
if ! isProject ${PROJECT_NAME}; then
  failChk oc new-project ${PROJECT_NAME} > /dev/null
fi

rm -rf ${BASE_PATH}/install 
rm -rf ${BASE_PATH}/examples
failChk unzip -qq ${BASE_PATH}/amq-streams-*.*.*-ocp-install-examples*.zip -d ${BASE_PATH}/

failChk oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

# Deploying the cluster operator
# ------------------------------------------------------------------
echo "Deploying cluster operator..."
if [ "${USE_OPERATOR_HUB,,}" == "true" ]; then
  rm -f ${BASE_PATH}/my_operatorgroup.yaml 
  rm -f ${BASE_PATH}/my_sub.yaml
  cp ${BASE_PATH}/operatorgroup.yaml ${BASE_PATH}/my_operatorgroup.yaml
  cp ${BASE_PATH}/sub.yaml ${BASE_PATH}/my_sub.yaml
  sed -i -e 's/<namespace>/'"${CLUSTER_OP_NS}"'/' ${BASE_PATH}/my_operatorgroup.yaml
  sed -i -e 's/  namespace: openshift-operators/  namespace: '"${CLUSTER_OP_NS}"'/' ${BASE_PATH}/my_sub.yaml

  failChk oc apply -f ${BASE_PATH}/my_operatorgroup.yaml
  failChk oc apply -f ${BASE_PATH}/my_sub.yaml
  CLUSTER_OP_NAME="amq-streams-cluster-operator"
else
  sed -i 's/namespace: .*/namespace: '"${CLUSTER_OP_NS}"'/' ${CLUSTER_OP_PATH}/*RoleBinding*.yaml
  failChk oc create -f ${CLUSTER_OP_PATH} -n ${CLUSTER_OP_NS}
  CLUSTER_OP_NAME="strimzi-cluster-operator"
fi
  
# Wait for deployment success
echo "Waiting for deployments to become available..."
AVAILABLE="0"
while [ "${AVAILABLE}" != "1" ]; do
  sleep 1
  AVAILABLE=$(oc get deployments -n ${CLUSTER_OP_NS} 2>/dev/null | grep ${CLUSTER_OP_NAME} | tr -s ' ' | cut -d ' ' -f4)
done
echo "${CLUSTER_OP_NAME} is ready"
# ------------------------------------------------------------------

# Deploying Kafka
# ------------------------------------------------------------------
echo "Deploying kafka instance..."
sed -i -e 's/    config:/      - name: listener1\n        port: 9094\n        type: route\n        tls: true\n    config:/' \
       -e 's/  name: my-cluster/  name: '"${CLUSTER_NAME}"'\n  namespace: '"${CLUSTER_OP_NS}"'/' \
       ${KAFKA_CRD_PATH}/${KAFKA_PERSISTENCE}
failChk oc apply -f ${KAFKA_CRD_PATH}/${KAFKA_PERSISTENCE}

echo "Waiting for deployments to become available..."
clusterPods=("-entity-operator"  "-kafka-0"  "-kafka-1"  "-kafka-2"  "-zookeeper-0"  "-zookeeper-1"  "-zookeeper-2")
for pod in ${clusterPods[*]}; do
  # Wait for deployment success
  AVAILABLE="0"
  while [ "${AVAILABLE}" != "Running" ]; do
    sleep 1
    AVAILABLE=$(oc get pods -n ${CLUSTER_OP_NS} | grep -e "${pod}" | tr -s ' ' | cut -d ' ' -f3)
  done
  echo "Kafka Cluster pod: ${pod} is ready!"
done

# Create Topic
echo "Deploying kafka topic..."
failChk oc apply -f ${BASE_PATH}/kafkaTopic.yaml
# ------------------------------------------------------------------

# Get External route to Bootstrap server
oc get routes ${CLUSTER_NAME}-kafka-listener1-bootstrap -o=jsonpath='{.status.ingress[0].host}{"\n"}'

rm -f ${DEMO_PATH}/ca.crt
rm -f ${DEMO_PATH}/client.truststore.jks

# Get public certificate
oc extract secret/${CLUSTER_NAME}-cluster-ca-cert --keys=ca.crt --to=- > ${DEMO_PATH}/ca.crt

# Create a local truststore (java only)
keytool -keystore ${DEMO_PATH}/client.truststore.jks -alias CARoot -importcert -file ${DEMO_PATH}/ca.crt -storepass redhat -noprompt

# <cluster_name>-kafka-<listener_name>-bootstrap-<namespace>
BOOTSTRAP_SERVER="$(oc get routes ${CLUSTER_NAME}-kafka-${LISTENER_NAME}-bootstrap -o=jsonpath='{.status.ingress[0].host}' -n ${PROJECT_NAME}):443"

sed -i -e 's/^BOOTSTRAP=.*$/BOOTSTRAP='"${BOOTSTRAP_SERVER}"'/' ${DEMO_PATH}/consoleConsumer.sh
sed -i -e 's/^BOOTSTRAP=.*$/BOOTSTRAP='"${BOOTSTRAP_SERVER}"'/' ${DEMO_PATH}/consoleProducer.sh

