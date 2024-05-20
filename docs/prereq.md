# Prerequisites

## OpenShift

To get started you will need an OpenShift environment.  In developing this demo I made extensive use of **OpenShift Local** (aka CodeReadyContainers).  You do not have to use OpenShift Local, andy OpenShift installation will do.  

You will need developer (regular user) ***and*** administrator IDs for OpenShift.

You will also need the `oc` tool preinstalled.  If you are using OpenShift Local then the scripts can source the `oc` binary shipped with that for you.

## Quay.io

This demo utilizes Quay.io to serve as an external container registry.  You will need a login for Quay.io.  You can register for a free Red Hat account which can be used with Quay.io.

Also I recommend generating a token in Quay.io for you credentials.  You can do this by generating an encrypted password in the **Docker CLI Password** section under Quay's `account settings`, or you can create a robot account.  A robot account is simply a named token.  These approaches are prefereable to using your actual password in scripts. 

## Red Hat Container Registry Credentials

Some of the container images used by this demo require authentication with Red Hat's container registry.  Red Hat provides a tool for registering named tokens for use with service accounts etc.  You can create a token by going to [Red Hat Customer Portal - Token Generation](https://access.redhat.com/terms-based-registry/).  For more information regarding this and related topics please refer to [Red Hat Container Registry Authentication](https://access.redhat.com/RegistryAuthentication).

## AMQ Streams

In order to script the installation of AMQ Streams the demo uses YAML resource definitions provided by Red Hat.  The file link is below:

File: [amq-streams-2.6.0-ocp-install-examples.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDetail.html?softwareId=106108&product=jboss.amq.streams&version=2.6.0&downloadType=distributions)

In order to test the setup of AMQ Streams before demoing, and also to monitor AMQ Streams during the demo, we will use the command line clients provided by Red Hat (For more information click [here](https://access.redhat.com/documentation/en-us/red_hat_amq_streams/2.6/html-single/getting_started_with_amq_streams_on_openshift/index#proc-using-amq-streams-str)).  The file link is below:

File: [amq-streams-2.6.0-bin.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDetail.html?softwareId=106110&product=jboss.amq.streams&version=2.6.0&downloadType=distributions)  

The details for these files is also available in the repository text file [RequiredFiles.txt](zip_files/RequiredFiles.txt). 

---

[[back](../README.md#getting-started)]
