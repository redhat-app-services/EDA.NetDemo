# The Event Consumer Service

See [this](webAPI.md) section to understand how a .NET project is generally setup.  The eventConsumer service is deployed in Serverless.  It expects a CloudEvent.  A KafkaSource is configured to listen to AMQ Streams on a specified topic.  When a kafka message is received by the KafkaSource is sends a CloudEvent over HTTP to the eventConsumer service containing the message payload.

## Installing the nuget Packages

This service utilized the following nuget packages.  Installation is as follows:

```
dotnet add package CloudNative.CloudEvents --version 2.7.0
dotnet add package CloudNative.CloudEvents.AspNetCore --version 2.7.0
dotnet add package CloudNative.CloudEvents.NewtonsoftJson --version 2.7.0
dotnet add package System.Data.SqlClient
```

## Running the Application Locally

To run the application locally (in Development mode) simply issue the command:

```
dotnet run
```

The startup messages will indicate the port the web server is listening on.  In my case the server was listening on `http://localhost:5072/`. We can invoke the service from the commandline using curl:

```bash
curl http://localhost:5072/ \
  -H "Content-Type: application/cloudevents+json" \
  -d '{
        "specversion": "1.0",
        "type": "com.mycompany.myapp.myservice.myevent",
        "source": "curl",
        "id": "1234-5678",
        "time": "2023-01-02T12:34:56.789Z",
        "subject": "my-important-subject",
        "data": {
          "message": "Hello",
          "foo": "bar"
        }
      }'
```

Notice that the spaces in the `message` parameter value uses encoded spaces (`%20`).  This is because a valid URL does not have spaces.

# Deploying the Application to OpenShift

With this service we demonstrate compiling the code and building the container all outside of OpenShift.  Before doing so we will need to install the .NET image streams.  For instructions on installing the prerequisite image streams see [here](prereq.md).

## Generating .NET Binaries Outside of OpenShift

When we are ready to build the application for deployment we can issue the following:

```dotnet
dotnet publish myWebApp -f net7.0 -c Release
```

We can then deploy in OpenShift using the oc command as follows:

```bash
# Building .net release...
dotnet publish -f net7.0 -c Release

# Building new image (with version tag)
podman build --layers=false -t ${IMAGE_NAME}:${VERSION} .

# Tag image with latest tag since many expect it
podman tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

# Login to your container registry...
podman login -u="${QUAY_USER}" -p="${QUAY_TOKEN}" quay.io

# Pushing image to quay.io...
podman push ${IMAGE_NAME}:${VERSION}
podman push ${IMAGE_NAME}

# Create OpenShift project to deploy our container...
oc new-project kafka-cons

# Deploy the container with our serverless resource definition
oc apply -f ${CRD_PATH}/event-consumer.yml

# Create KafkaSource 
oc apply -f ${CRD_PATH}/kafkaSource.yml
```

The key part of the `event-consumer.yml` looks like this:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-consumer
  namespace: kafka-cons
spec:
  template:
    spec:
      containers:
        - image: quay.io/QUAY_USER/eventconsumer:1.5
          env:
            - name: DB_CONN_STR
              valueFrom:
                configMapKeyRef:
                  name: kafka-cons-conf
                  key: DB_CONN_STR
```

Notice The `apiVersion` indicates that this is a serverless deployment with `serving.knative.dev/v1`.  The `kind` property is set to `Service` as we would expect.

---

[[back](../README.md#getting-started)]
