#!/bin/bash

BOOTSTRAP=my-cluster-kafka-listener1-bootstrap-amq-streams-kafka.apps-crc.testing:443

if [ ! -d "kafka_2.13-3.4.0.redhat-00006" ]; then
 unzip -qq amq-streams-2.4.0-bin.zip 
fi

kafka_2.13-3.4.0.redhat-00006/bin/kafka-console-consumer.sh \
--bootstrap-server ${BOOTSTRAP} \
--consumer-property security.protocol=SSL \
--consumer-property ssl.truststore.password=redhat \
--consumer-property ssl.truststore.location=client.truststore.jks \
--topic my-topic --from-beginning
