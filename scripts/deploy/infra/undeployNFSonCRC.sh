#!/bin/bash
# https://developers.redhat.com/articles/2022/04/20/create-and-manage-local-persistent-volumes-codeready-containers

source ../../common_cfg

# paths
BASE_PATH=../../../yaml/nfs

# login
oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

# ensure we are using the 'nfsprovisioner-operator' project
oc project nfsprovisioner-operator > /dev/null

# remove nfs provisioner
oc delete -f ${BASE_PATH}/nfs_provisioner.yaml

# remove operator subscription
oc delete -f ${BASE_PATH}/nfs_sub.yaml

# restore default storageclass
oc patch sc/crc-csi-hostpath-provisioner -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# remove nfs storageclass
oc delete sc/nfs

# Set Env variable for the target node name
target_node=$(oc get node --no-headers -o name | cut -d'/' -f2)

# Remove app label
oc label node/${target_node} app-

# Move out of 'nfsprovisioner-operator' project
oc project default

