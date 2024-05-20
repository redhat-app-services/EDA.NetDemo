#!/bin/bash

source ../../common_cfg

# paths
BASE_PATH=../../../yaml/knative


oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

#  Uninstalling Knative Eventing
oc delete knativeeventings.operator.knative.dev knative-eventing -n knative-eventing
oc delete namespace knative-eventing

#  Uninstalling Knative Serving
oc delete knativeservings.operator.knative.dev knative-serving -n knative-serving
oc delete namespace knative-serving

# Uninstall Operator
oc delete -f ${BASE_PATH}/serverless-sub.yaml

# Remove Serverless yaml
oc get crd -oname | grep 'knative.dev' | xargs oc delete
