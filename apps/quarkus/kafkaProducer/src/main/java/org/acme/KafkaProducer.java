package org.acme;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.jboss.resteasy.reactive.RestForm;

import io.smallrye.reactive.messaging.kafka.KafkaRecord;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.MediaType;

@Path("/api/kafka")
public class KafkaProducer 
  {
    @Channel("kafka") 
    Emitter<String> emitter;

    @ConfigProperty(name = "mp.messaging.outgoing.kafka.topic")
    String topic;

    public String send(String payload)
      { 
        emitter.send(KafkaRecord.of(topic, "message", payload).withHeader("Content-Type", "application/json"));
        return "";                 
      }

    @POST
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    public String allParams(@RestForm String message) 
      {
        send(message);
        return message;
      }
  }