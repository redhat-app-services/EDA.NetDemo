#!/bin/bash

FILENAME="amq-streams-2.4.0-ocp-install-examples.zip"

if [ -f "${FILENAME}" ]; then
  echo "Moving file '${FILENAME}'"
  mv ${FILENAME} ../yaml/kafka/
fi

FILENAME="amq-streams-2.4.0-bin.zip"

if [ -f "${FILENAME}" ]; then
  echo "Moving file '${FILENAME}'"
  mv ${FILENAME} ../scripts/demo/kafka/
fi


