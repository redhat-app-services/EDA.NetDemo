# Deploying Demo Apps

This demo uses two application service written in .NET (C#).  The deployment scripts are located in the `scripts/deploy/app` folder.

![](.img/scripts_app.png)

`deployKafkaProd.sh` deploys the Kafka message producer service.  This service receives an `HTTP` `POST` request and puts the `JSON` payload onto AMQ Streams as a message.

This script leverages using secrets and configmaps with the service.  It also makes use of OpenShift's `Source-to-Image` (`S2I`) capability.  `S2I` is a standard process within OpenShift that automates the source compilation and container build for applications.  Although we have not done so here, you can augment this process by making `S2I` part of a build pipeline.

`deployEventCons.sh` deploys a serverless service that consumes events generated from Kafka messages.  It then persists the `JSON` payload to a containerized SQL Server instance.

This script demonstrates using .NET build techniques and builds the container using podman.  The script then tags and pushes the container to the quay.io user repository.  It then deploys the container to OpenShift using a `YAML` resource definition.  

In this script you will want to look at the following variables.

```bash
# Code version
VERSION=1.5

# Rebuild code or just deploy container with this version tag
REBUILD=true
```

`VERSION` is where you specify the version label the container should be tagged with.  You will want to increment this value for consecutive builds.

`REBUILD` is a boolean setting that toggles whether we need to build a new container or just deploy and existing container from Quay.io.

---

[[back](../README.md#getting-started)]
