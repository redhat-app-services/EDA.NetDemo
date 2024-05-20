#!/bin/bash
source ../common_cfg

oc login ${OC_LOGIN_KUBEADMIN} > /dev/null
if [ $? -eq 0 ]; then
  echo "Login successful!!"
  echo " "
fi

