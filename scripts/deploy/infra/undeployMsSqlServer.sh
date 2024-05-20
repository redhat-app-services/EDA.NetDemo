#!/bin/bash

source ../../common_cfg

# OCP project name
PROJECT_NAME=mssql


oc login ${OC_LOGIN_DEVELOPER} > /dev/null
if isProject ${PROJECT_NAME}; then
  oc delete project ${PROJECT_NAME}
fi

