#!/bin/bash

source ../../common_cfg

INSTALL_LOGFILE="./install.log"
DEPLOY_EVERYTHING="TRUE"
startTime=$(date +"%s")

# Seconds to wait before deploying next part
SETTLING_TIME=0

function bannerMsg()
  {
    sleep ${SETTLING_TIME}
    echo " "
    echo "=============================================="
    echo " $1"
    echo "=============================================="
    echo " "
  }

function pipedErrChck()
  {
    if [ ${PIPESTATUS[0]} -gt 0 ]; then
      echo "Failed $1" | tee ${INSTALL_LOGFILE}
      runTime=$(getRuntime)
      echo "Total run time: ${runTime}." | tee ${INSTALL_LOGFILE}
      echo " " | tee -a ${INSTALL_LOGFILE}
      exit 1
    fi
  }

function getRuntime()
  {
    endTime=$(date +"%s")
    duration=$(( endTime - startTime ))
    seconds=$((duration%60))
    minutes=$(((duration/60)%60))
    hours=$(((duration/3600)%24))
    runtime=""
    hrs=false
    min=false
    sec=false

    if [ ${hours} -gt 0 ]; then
      runtime="${hours} hours, "
      hrs=true
    fi
    if [ ${minutes} -gt 0 ] || ${hrs}; then
      runtime="${runtime}${minutes} min, "
    fi
    if [ ${seconds} -gt 0 ]; then
      runtime="${runtime}${seconds} seconds"
    fi

    echo "${runtime}"
  }

clear
bannerMsg "Deploying Serverless" | tee ${INSTALL_LOGFILE}
. ./deployServerless.sh 2>&1 | tee -a ${INSTALL_LOGFILE}
pipedErrChck "Deploying Serverless"

SETTLING_TIME=5
bannerMsg "Deploying AMQ Streams" | tee -a ${INSTALL_LOGFILE}
. ./deployAMQStreams.sh 2>&1 | tee -a ${INSTALL_LOGFILE}
pipedErrChck "Deploying AMQ Streams"

bannerMsg "Deploying SQL Server" | tee -a ${INSTALL_LOGFILE}
. ./deployMsSqlServer.sh 2>&1 | tee -a ${INSTALL_LOGFILE}
pipedErrChck "Deploying SQL Server"

bannerMsg "Deploying CloudBeaver" | tee -a ${INSTALL_LOGFILE}
. ./deployCloudBeaver.sh 2>&1 | tee -a ${INSTALL_LOGFILE}
pipedErrChck "Deploying CloudBeaver"

bannerMsg "Deploying .Net imagestreams" | tee -a ${INSTALL_LOGFILE}
. ./deployDotNetIS.sh 2>&1 | tee -a ${INSTALL_LOGFILE}
pipedErrChck "Deploying .Net imagestreams"

bannerMsg "Deploying NFS" | tee -a ${INSTALL_LOGFILE}
. ./deployNFSonCRC.sh 2>&1 | tee -a ${INSTALL_LOGFILE}
pipedErrChck "Deploying NFS"

bannerMsg "Deploying 3Scale" | tee -a ${INSTALL_LOGFILE}
. ./deploy3scale.sh 2>&1 | tee -a ${INSTALL_LOGFILE}
pipedErrChck "Deploying 3Scale"

runTime=$(getRuntime)
echo "Total run time: ${runTime}" | tee -a ${INSTALL_LOGFILE}
echo " " | tee -a ${INSTALL_LOGFILE}

