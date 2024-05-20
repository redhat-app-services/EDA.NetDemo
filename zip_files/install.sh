#!/bin/bash

FILENAME=$(ls amq-streams-*.*.*-ocp-install-examples-*.zip)

if [ -f "${FILENAME}" ]; then
  echo "Moving file '${FILENAME}'"
  cp ${FILENAME} ../yaml/kafka/
fi

FILENAME=$(ls amq-streams-*.*.*-bin.zip)

if [ -f "${FILENAME}" ]; then
  echo "Moving file '${FILENAME}'"
  cp ${FILENAME} ../scripts/demo/kafka/
fi


