# The kafkaProducer API Service

See [this](webAPI.md) section to understand how this project was initially setup.  The kafkaProducer service connects to AMQ Streams and registers as a producer.  For kafka API support in .NET we made use of the `Confluent.Kafka` nuget package.

## Installing the Confluent.Kafka nuget Package

In order to connect to Kafka from .NET, we need to install the Confluent.Kafka package.  The package version we made use of is 2.2.0.  Installation is as follows:

```
dotnet add package Confluent.Kafka --version 2.2.0
```

## Running the Application Locally

To run this application outside of OpenShift connecting to an AMQ Streams cluster running in OpenShift we will need to set some environment variables:  

```bash
KAFKA_BOOTSTRAP="my-cluster-kafka-listener1-bootstrap-amq-streams-kafka.apps-crc.testing:443"
KAFKA_SEC_PROTO="Ssl"
KAFKA_SSL_CA_LOC="/demo/kafka/ca.crt"
KAFKA_PROD_CLIENTID="KafkaProducerMicroservice"
KAFKA_TOPIC="my-topic"
```

To run the application locally (in Development mode) simply issue the command:

```
dotnet run
```

The startup messages will indicate the port the web server is listening on.  In my case the server was listening on `http://localhost:5253/`. We can invoke the service from the commandline using curl:

```bash
curl -H "Content-Length: 0" -X POST "http://localhost:5253/api/kafka?message=Surpise%20another%20one%20bites%20the%20dust"
```

Notice that the spaces in the `message` parameter value uses encoded spaces (`%20`).  This is because a valid URL does not have spaces.

# Deploying the Application to OpenShift

There are two ways we can approach deploying the application to OpenShift.  The first is a more manual process of working with an existing binary.  Before doing so we will need to install the .NET image streams.  For instructions on installing the prerequisite image streams see [here](prereq.md).

## Generating .NET Binaries Outside of OpenShift

When we are ready to build the application for deployment we can issue the following:

```
cd ..
dotnet publish myWebApp -f net7.0 -c Release
```

We can then deploy in OpenShift using the oc command as follows:

```
oc new-build --name=my-web-app dotnet:7.0-ubi8 --binary=true
oc start-build my-web-app --from-dir=myWebApp/bin/Release/net7.0/publish
oc logs -f bc/my-web-app
oc new-app my-web-app
oc status
oc expose svc/my-web-app
oc get route
```

## Leveraging Source-to-Image Deployment Strategy

If we store our application code in a git repository, we can have OpenShift pull and build the application directly from there.  The S2I process will also deploy the application.

```
oc new-project dotnet-project
oc new-app --name=dotnet-app \
   'dotnet:7.0-ubi8~https://github.com/ajhajj/dotNet#main' \
   --build-env DOTNET_STARTUP_PROJECT=myWebApp
oc logs -f bc/dotnet-app
oc logs -f deployment/dotnet-app
oc expose svc/dotnet-app
oc get routes
```

---

[[back](../README.md#getting-started)]
