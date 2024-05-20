#!/bin/bash

source ../../common_cfg

# OCP project name
PROJECT_NAME=amq-streams-kafka


oc login ${OC_LOGIN_KUBEADMIN} > /dev/null
oc delete subscription.operators.coreos.com/amq-streams
oc delete operatorgroup.operators.coreos.com/amq-streams
oc delete serviceaccount/strimzi-cluster-operator 
oc delete rolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator 
oc delete rolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator-leader-election 
oc delete rolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator-watched 
oc delete rolebinding.rbac.authorization.k8s.io/strimzi-cluster-operator-entity-operator-delegation 
oc delete configmap/strimzi-cluster-operator 
oc delete deployment.apps/strimzi-cluster-operator
oc delete deployment.apps/amq-streams-cluster-operator
oc delete clusterroles.rbac.authorization.k8s.io strimzi-cluster-operator-namespaced
oc delete clusterroles.rbac.authorization.k8s.io strimzi-cluster-operator-global
oc delete clusterrolebindings.rbac.authorization.k8s.io strimzi-cluster-operator
oc delete clusterroles.rbac.authorization.k8s.io strimzi-cluster-operator-leader-election
oc delete clusterroles.rbac.authorization.k8s.io strimzi-cluster-operator-watched
oc delete clusterroles.rbac.authorization.k8s.io strimzi-kafka-broker
oc delete clusterrolebindings.rbac.authorization.k8s.io strimzi-cluster-operator-kafka-broker-delegation
oc delete clusterroles.rbac.authorization.k8s.io strimzi-entity-operator
oc delete clusterroles.rbac.authorization.k8s.io strimzi-kafka-client
oc delete clusterrolebindings.rbac.authorization.k8s.io strimzi-cluster-operator-kafka-client-delegation
oc delete customresourcedefinitions.apiextensions.k8s.io kafkas.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkaconnects.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io strimzipodsets.core.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkatopics.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkausers.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkamirrormakers.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkabridges.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkaconnectors.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkamirrormaker2s.kafka.strimzi.io
oc delete customresourcedefinitions.apiextensions.k8s.io kafkarebalances.kafka.strimzi.io

if isProject ${PROJECT_NAME}; then
  oc delete project ${PROJECT_NAME}
fi

