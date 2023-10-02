#!/bin/bash

if [ ${#DEPLOY_EVERYTHING} -eq 0 ]; then
  clear
  source ../../common_cfg
fi

failChk oc login ${OC_LOGIN_KUBEADMIN} > /dev/null

failChk oc project openshift >/dev/null 2>&1
failChk oc describe is dotnet >/dev/null 2>&1
if [ "$?" == "1" ];then
  # 1 = error
  echo "Installing dotNet imagestreams"
  failChk oc create -f https://raw.githubusercontent.com/redhat-developer/s2i-dotnetcore/master/dotnet_imagestreams.json
else
  echo "Updating dotNet imagestreams"
  failChk oc replace -f https://raw.githubusercontent.com/redhat-developer/s2i-dotnetcore/master/dotnet_imagestreams.json
fi
