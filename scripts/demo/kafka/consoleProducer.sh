#!/bin/bash

BOOTSTRAP=my-cluster-kafka-listener1-bootstrap-amq-streams-kafka.apps-crc.testing:443
ls -d kafka_*.*-*.*.*.redhat-0000? 2>/dev/null

if [ $? -gt 0 ]; then
  unzip -qq amq-streams-*.*.*-bin.zip
fi

FOLDER=$(ls -d kafka_*.*-*.*.*.redhat-0000?)

${FOLDER}/bin/kafka-console-producer.sh \
--bootstrap-server ${BOOTSTRAP} \
--producer-property security.protocol=SSL \
--producer-property ssl.truststore.password=redhat \
--producer-property ssl.truststore.location=client.truststore.jks \
--topic my-topic

