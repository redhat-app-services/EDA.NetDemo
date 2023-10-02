#!/bin/bash
# https://developers.redhat.com/articles/2022/04/20/create-and-manage-local-persistent-volumes-codeready-containers

if [ ${#DEPLOY_EVERYTHING} -eq 0 ]; then
  clear
  source ../../common_cfg
fi

# paths
BASE_PATH=../../../yaml/nfs

PODNAME_PATTERN="nfs-provisioner"
NAMESPACE="nfsprovisioner-operator"

function findPod()
{
  # pod name should be like nfs-provisioner-77bc99bd9c-57jf2
  oc get pods -n ${NAMESPACE} 2> /dev/null | grep "${PODNAME_PATTERN}-.......*-....."
}

# login
failChk oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

# apply subscription yaml
failChk oc apply -f ${BASE_PATH}/nfs_sub.yaml

# switch to namespace 
failChk oc project ${NAMESPACE}

# Set Env variable for the target node name
target_node=$(oc get node --no-headers -o name | cut -d'/' -f2)
failChk oc label node/${target_node} app=nfs-provisioner

# ssh to the node
cat <<EOF | oc debug node/${target_node} 2>&1 >/dev/null
chroot /host
rm -rf /home/core/nfs
mkdir -p /home/core/nfs
chcon -Rvt svirt_sandbox_file_t /home/core/nfs
exit
exit
EOF

# Allow for any settling time
sleep 15
ABS_PATH="$(realpath -e ${BASE_PATH}/nfs_provisioner.yaml)"
failChk oc apply -f ${ABS_PATH}

POD=$(findPod | sed -e 's/ .*$//')
len=${#POD}
if [ ${len} -eq 0 ]; then
  echo "Waiting for service pod to start..."

  while [ ${len} -eq 0 ]; do
    sleep 1
    POD=$(findPod | sed -e 's/ .*$//')
    len=${#POD}
  done
  echo "Pod started."
fi

status=$(findPod | tr -s ' ' | cut -d ' ' -f 3)
if [ "${status}" != "Running" ]; then
  echo "Waiting for pod '${POD}' to be ready..."

  while [ "${status}" != "Running" ]; do
    sleep 1
    status=$(findPod | tr -s ' ' | cut -d ' ' -f 3)
  done
  echo "Pod ready."
fi

# Check if NFS Server is running (pod name should be like nfs-provisioner-77bc99bd9c-57jf2)
failChk oc get pods

# Wait for storageclass nfs to become available for patching
TEST=$(oc get sc/nfs 2>&1 | grep "Error from server (NotFound)" > /dev/null; echo $?)
while [ ${TEST} -eq 0 ]; do
  sleep 1
  TEST=$(oc get sc/nfs 2>&1 | grep "Error from server (NotFound)" > /dev/null; echo $?)
done

sleep 2

# Update annotation of the NFS StorageClass
oc patch sc/crc-csi-hostpath-provisioner -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
oc patch sc/nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Make sure the nfs StorageClass is reporting as default
# NAME            PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
# nfs (default)   example.com/nfs   Delete          Immediate           false                  4m29s
failChk oc get sc

