#!/bin/bash
source ../common_cfg

PODNAME_PATTERN="event-consumer"
NAMESPACE="kafka-cons"

function findPod()
{
  oc get pods -n ${NAMESPACE} 2> /dev/null | grep "${PODNAME_PATTERN}-.......*-....."
}

oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

clear

EV_CONS_POD=$(findPod | sed -e 's/ .*$//')
len=${#EV_CONS_POD}
if [ ${len} -eq 0 ]; then
  echo "Waiting for ${NAMESPACE} service pod to start..."

  while [ ${len} -eq 0 ]; do
    sleep 1
    EV_CONS_POD=$(findPod | sed -e 's/ .*$//')
    len=${#EV_CONS_POD}
  done
  echo "Pod started."
fi

status=$(findPod | tr -s ' ' | cut -d ' ' -f 3)
if [ "${status}" != "Running" ]; then
  echo "Waiting for pod '${EV_CONS_POD}' to be ready..."

  while [ "${status}" != "Running" ]; do
    sleep 1
    status=$(findPod | tr -s ' ' | cut -d ' ' -f 3)
  done
  echo "Pod ready."
fi

echo " "
echo "Tailing logs:"
oc logs -f ${EV_CONS_POD} -n ${NAMESPACE}

