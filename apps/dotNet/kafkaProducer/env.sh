#!/bin/bash

export KAFKA_BOOTSTRAP="my-cluster-kafka-listener1-bootstrap-amq-streams-kafka.apps-crc.testing:443"
export KAFKA_SEC_PROTO="Ssl"
export KAFKA_SSL_CA_LOC="../../../scripts/demo/kafka/ca.crt"
export KAFKA_PROD_CLIENTID="KafkaProducerMicroservice"
export KAFKA_TOPIC="my-topic"

