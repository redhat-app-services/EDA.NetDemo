#!/bin/bash

if [ ${#DEPLOY_EVERYTHING} -eq 0 ]; then
  clear
  source ../../common_cfg
fi

# paths
BASE_PATH=../../../yaml/knative

# Operator name
CLUSTER_OP_NAME="Red Hat OpenShift Serverless"

# Operator namespace
CLUSTER_OP_NS=openshift-serverless

failChk oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

echo "Installing '${CLUSTER_OP_NAME}'..."
failChk oc apply -f ${BASE_PATH}/serverless-sub.yaml > /dev/null

# Wait for deployment success
echo "Waiting for '${CLUSTER_OP_NAME}' to be ready..."
STATUS="pending"
while [ "${STATUS,,}" != "succeeded" ]; do
  sleep 1
  STATUS=$(oc get csv -n ${CLUSTER_OP_NS} 2>/dev/null | grep "${CLUSTER_OP_NAME}" | sed -e 's/^.* //' | tr -s ' ')
done
echo "'${CLUSTER_OP_NAME}' is ready"

echo "Installing 'knative serving'..."
failChk oc apply -f ${BASE_PATH}/serving.yaml > /dev/null

# Wait for CSV start
echo "Waiting for 'knative serving' to be ready..."
STATUS=0
size=1
while [ "${size}" -gt 0 ] && [ "${STATUS}" != "1" ]; do
  sleep 1
  STATUS=$(oc get knativeserving.operator.knative.dev/knative-serving -n knative-serving --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}')
  size=${#STATUS}
  echo ${STATUS} | grep "False" 2>&1>/dev/null
  STATUS="$?"
done

# Wait for pod resources
echo "Checking for pods to come up..."
podCount=0
while [ "${podCount}" != 10 ]; do
  sleep 1
  podCount=$(oc get pods -n knative-serving 2>/dev/null | \
    grep '^activator-\|^autoscaler-\|^controller-\|^domain-mapping-\|^domainmapping-webhook-\|^webhook-' | \
    grep " 2/2 " | wc -l)
done
echo "  * 'knative serving' pod resource ready"

# Wait for networking resources
podCount=0
while [ "${podCount}" != 4 ]; do
  sleep 1
  podCount=$(oc get pods -n knative-serving-ingress | \
    grep '^3scale-kourier-gateway-\|^net-kourier-controller-' | \
    grep " 1/1 " | wc -l)
done
echo "  * 'knative serving' networking resources ready"
echo "  * 'knative serving' is ready"

echo "Installing 'knative eventing'..."
failChk oc apply -f ${BASE_PATH}/eventing.yaml > /dev/null

# Wait for pod resources
podCount=0
while [ "${podCount}" != 10 ]; do
  sleep 1
  podCount=$(oc get pods -n knative-eventing 2>/dev/null | \
    grep 'broker-controller-\|^eventing-controller-\|^eventing-webhook-\|^imc-controller-\|^imc-dispatcher-' | \
    grep " Running " | wc -l)
done
echo "  * 'knative eventing' pod resource ready"

# Verify the knative eventing installation is complete
echo "Waiting for 'knative eventing' to be ready..."
STATUS=0
size=0
while [ "${size}" -gt 0 ] && [ "${STATUS}" != "1" ]; do
  sleep 1
  STATUS=$(oc get knativeeventing.operator.knative.dev/knative-eventing -n knative-eventing --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}')
  size=${#STATUS}
  echo ${STATUS} | grep "False" 2>&1>/dev/null
  STATUS="$?"
done
echo "  * 'knative eventing' installation is complete"

echo "Installing 'knative kafka broker'..."
failChk oc apply -f ${BASE_PATH}/knativekafka.yaml > /dev/null
echo "Finished"
