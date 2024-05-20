#!/bin/bash

if [ ${#DEPLOY_EVERYTHING} -eq 0 ]; then
  clear
  source ../../common_cfg
fi

# paths
SQL_PATH=../../demo/database

# OCP project name
PROJECT_NAME=mssql-client

oc login ${OC_LOGIN_DEVELOPER} > /dev/null
if ! isProject ${PROJECT_NAME}; then
  failChk oc new-project ${PROJECT_NAME} > /dev/null
fi

#failChk oc new-app --name cloudbeaver --image dbeaver/cloudbeaver:latest
failChk oc new-app --name cloudbeaver --image dbeaver/cloudbeaver:23.3
failChk oc expose service/cloudbeaver
failChk oc get routes

echo "========================================================================"
echo "Connection and SQL info:"
echo "========================================================================"
echo "URL: jdbc:sqlserver://;serverName=sqlserver.mssql.svc.cluster.local;databaseName=kafka_events"
echo "sa:redHat2023!"
echo "createDB: ./${SQL_PATH}/create.sql"
echo "dropDB: ./${SQL_PATH}/drop.sql"
echo "queryDB: ./${SQL_PATH}/query.sql"

echo "========================================================================"


