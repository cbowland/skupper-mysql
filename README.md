# Service Interconnect for Remote Database Access

[website]: https://skupper.io/

#### Contents
* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Step 1: Install Red Hat Service Interconnect](#step-1-install-red-hat-service-interconnect)
* [Step 2: Set Up Environment Variables](#step-2-set-up-environment-variables)
* [Step 3: Set Path To Demo Magic](#step-3-set-path-to-demo-magic)
* [Step 4: Run The Demo](#step-4-run-the-demo)

## Overview

This example uses a MySQL database running in one OpenShift clutser
and connecting to that database from a different OpenShift cluster
over the skupper Virtual Application Network (VAN) and without exposing
the database outside of the VAN.

NOTE: This demo is very heavy with command line usage. The best way to deliver
the demo is to provide your own talk track as you move through the demo. You can 
also move back and forth between the command line and the OpenShift Web 
Consoles to explain what is happening. For example, you might show that 
the demo does not create a traditonal OpenShift service for the database
and that the Skupper sevice that is created points to the Skupper router
and not the database pod itself.

The two clusters have the following services:

* The public cluster will have a MySQL database running with a small
set of sample data. This databae will be created as part of the demo.

* The second cluster will run a MySQL client in a container. That
process will run to completion each time. That is, the constainer will
start, connect to the database of the VAN, run a single query, and then 
the container will stop.

The goal is to show how a service / application can be added to the
Virtual Application Network and accessed remotely over the VAN without
needing to expose the service otherwise.

## Prerequisites

* Demo Magic (if you want to use the demo script)
  ([Git Hub Repo][demo-magic])

* The `oc` command-line tool, version 4.12 or later
  ([installation guide][install-oc-cli])

* The `skupper` command-line tool, version 1.4 or later
  ([installation guide][skupper-cli])

* Access to 2 Openshift clusters. This could also be done with a 
single cluster and 2 different projects.


[demo-magic]: https://github.com/paxtonhare/demo-magic
[install-oc-cli]: https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli
[skupper-cli]: https://access.redhat.com/documentation/en-us/red_hat_service_interconnect/1.4/html-single/installation/index#installing-skupper-cli
[Using Skupper with OpenShift]: https://skupper.io/start/openshift.html

## Step 1: Install Red Hat Service Interconnect 
Log into each cluster as a cluster admin and use the OpenShift  Operator Hub to install the Red Hat Service Interconnect Operator with default values.

## Step 2: Set Up Environment Variables

Inside the demo script, set the appropriate values for the
two OpenShift clusters.

_**Demo Script:**_
~~~ shell
PUBLIC_CLUSTER_USER=
PUBLIC_CLUSTER_PASSWORD=
PUBLIC_CLUSTER_API=
PUBLIC_CLUSTER_PROJECT=

PRIVATE_CLUSTER_USER=
PRIVATE_CLUSTER_PASSWORD=
PRIVATE_CLUSTER_API=
PRIVATE_CLUSTER_PROJECT=
~~~

## Step 3: Set Path To Demo Magic

Inside the demo script, set the path to your instance of the 
Demo Magic shell script.

_**Demo Script:**_
~~~ shell
# path to demo-magic.sh
DEMO_MAGIC=
~~~

## Step 4: Run The Demo

_**Demo Script:**_
~~~ shell
bash demo.sh
~~~

_Example Demo Magic Output_



https://github.com/cbowland/skupper-mysql/assets/1307303/552caa98-e284-46f4-b78d-f1d12788e6b4



## The Hard Way

If you do not want to use the demo script, you can peak 
inside of it and just run the commands directly and outside
of the provided demo script.

