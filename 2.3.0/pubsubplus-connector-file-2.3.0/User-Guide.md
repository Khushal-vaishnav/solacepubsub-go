# pubsubplus-connector-file: User Guide
Solace
Corporation https://solace.com

*Revision: 2.3.0*
<br/>*Revision Date: 2024-09-03*

## Table of Contents

-   [Preface]
-   [Getting Started]
    -   [Prerequisites]
    -   [Quick Start common steps]
    -   [Quick Start: Running the connector via command line]
    -   [Quick Start: Running the connector via `start.sh` script]
    -   [Quick Start: Running the connector as a Container]
-   [Enabling Workflows]
-   [Configuring Connection Details]
    -   [Solace PubSub+ Connection Details]
    -   [Connecting to Multiple Systems]
-   [User-configured Header Transforms]
-   [User-configured Payload Transforms]
    -   [Registered Functions]
-   [Message Headers]
    -   [Solace Headers]
    -   [Reserved Message Headers]
-   [Management and Monitoring Connector]
    -   [Monitoring Connector’s States]
-   [Health]
    -   [Workflow Health]
    -   [Solace Binder Health]
-   [Leader Election]
    -   [Leader Election Modes: Standalone / Active-Active]
    -   [Leader Election Mode: Active-Standby]
    -   [Leader Election Management Endpoint]
-   [Workflow Management]
    -   [Workflow Management Endpoint]
    -   [Workflow States]
-   [Metrics]
    -   [Connector Meters]
    -   [Add a Monitoring System]
-   [Security]
    -   [Securing Endpoints]
-   [Consuming Object Messages]
-   [Adding External Libraries]
-   [Configuration]
    -   [Providing Configuration]
    -   [Spring Configuration Options]
    -   [Connector Configuration Options]
    -   [Workflow Configuration Options]
-   [File Specific Configuration]
    -   [File Source Configuration Options]
    -   [File Sink Configuration Options]
-   [Remote Protocol Configuration]
    -   [Google Cloud Storage]
    -   [Secure File Transfer Protocol (SFTP)]
    -   [File Transfer Protocol (FTP/FTPs)]
-   [File Mesh Manager]
    -   [Configuration Options]
-   [License]
    -   [Support]

## Preface

Solace PubSub+ File Connector replicates files from Source to Sink

## Getting Started

Assuming you’re using the default `application.yml` within this package, following one of the below quick start guides will result in a connector that will connect to the PubSub+ broker and File using default credentials, with 2 workflows enabled, workflow 0 and workflow 1. Where:

-   Workflow 0 is consuming messages from the Solace PubSub+ queue, `Solace/Queue/0`, and publishing them to the File producer destination, `producer-destination`.

-   Workflow 1 is consuming messages from the File consumer destination, `consumer-destination`, and publishing them to the Solace PubSub+ topic, `Solace/Topic/1`.

A workflow is the configuration of a flow of messages from a source to a target. The connector supports up to 20 concurrent workflows per instance.

> **NOTE**
> 
> The connector will not provision queues which do not exist.

### Prerequisites

-   [Solace PubSub+ Event Broker]

-   File

When setting up file connector the following need to be configured on Solace Broker

1.  A queue for Sink Connector to consume file events sent by Source Connector.

2.  A LVQ to store the checkpoint data of Source Connector.

3.  A queue to store the heartbeat events sent by Source/Sink Connector.

4.  A queue to store the command center events sent by Source/Sink Connector.

The subscriptions for the above queues are mentioned in [Configuring Connection Details][1] and [Configuration][2] section

### Quick Start common steps

These are the steps that are required to run all quick-start examples:

1.  Update the provided `samples/config/application.yml` with the values for your deployment.

### Quick Start: Running the connector via command line

Run:

    java -jar pubsubplus-connector-file-2.3.0.jar --spring.config.additional-location=file:samples/config/

> **NOTE**
> 
> By default, this command detects any Spring Boot configuration files as per the [Spring Boot's default locations].
> 
> For more information, see [Configure Locations to Find Spring Property Files].
> 
>   [Spring Boot's default locations]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files
>   [Configure Locations to Find Spring Property Files]: #configure-locations-to-find-spring-property-files

### Quick Start: Running the connector via `start.sh` script

For convenience, you can start the connector through the shell script using the following command:

    chmod 744 ./bin/start.sh
    ./bin/start.sh [-n NAME] [-l FOLDER] [-p PROFILE] [-c FOLDER] [-ch HOST] [-cp PORT] [-j FILE] [-cm] [-cmh HOST] [-cmp PORT] [-mh HOST] [-mp PORT] [-o OPTIONS] [-b]

The script shows you all errors at the same time:

    ./bin/start.sh -l dummy_folder -c dummy_folder -j dummy_file.jar

The script shows you all errors at the same time:

    pubsubplus-connector-file

    Connector startup failed:

    Following folder doesn't exists on your filesystem:     'dummy_folder'
    Following folder doesn't exists on your filesystem:     'dummy_folder'
    Following file doesn't exists on your filesystem:       'dummy_file.jar'

In situations where you have don’t provide a parameter, the script runs with the predefined values as follows:

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Parameter</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>-n, --name</code></p></td>
<td style="text-align: left;"><p><code>application</code></p></td>
<td style="text-align: left;"><p>The name of the connector instance, that is configured in [spring.application.name]. This name impacts on grouping connectors only.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-l, --libs</code></p></td>
<td style="text-align: left;"><p><code>./libs</code></p></td>
<td style="text-align: left;"><p>The directory that contains the required and optional dependency JAR files, such as Micrometer metrics export dependencies (if configured). If this option is not specified, it will use the current <code>./libs/</code> directory.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>-p, --profile</code></p></td>
<td style="text-align: left;"><p><code>empty, no profile is used</code></p></td>
<td style="text-align: left;"><p>The profile to be used with the connector’s configuration. The configuration file named 'application-&lt;profile&gt;.yml' is used. If this option is not specified, no profile is used.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-c, --config</code></p></td>
<td style="text-align: left;"><p><code>./ or current folder</code></p></td>
<td style="text-align: left;"><p>The path to the folder containing the configuration files to be applied when the connector starts up the chosen profile. If not specified, the current directory is used.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>-H, --host</code></p></td>
<td style="text-align: left;"><p><code>127.0.0.1</code></p></td>
<td style="text-align: left;"><p>Specifies the host where the connector runs.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-P, --port</code></p></td>
<td style="text-align: left;"><p><code>8090</code></p></td>
<td style="text-align: left;"><p>Specifies the port where connector runs.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>-mp, --mgmt_port</code></p></td>
<td style="text-align: left;"><p><code>9009</code></p></td>
<td style="text-align: left;"><p>Specifies the management port for back calls of current connector from PubSub+ Connector Manager. This parameter is ignored if the <code>-cm</code> parameter is not provided.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-j, --jar</code></p></td>
<td style="text-align: left;"><p><code>pubsubplus-connector-file-2.3.0.jar</code></p></td>
<td style="text-align: left;"><p>The path to the specified JAR file to start the connector. If the option is not specified, the default JAR file is used from the current directory.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>-cm, --manager</code></p></td>
<td style="text-align: left;"><p><code>application</code></p></td>
<td style="text-align: left;"><p>Specifies PubSub+ Connector Manager to use the configuration storage and allows you to enable the cloud configuration for the connector. When this parameter is enabled, you can specify the <code>-mp</code> or <code>--mgmt_port</code>, <code>-H</code> or <code>--host</code>, and <code>-cmh</code> with the <code>-cmp</code> parameters, unless you want to use default values for those parameters. Be aware, this option disable listed parameters to be read from configuration file. In this case, the operator must explicitly specify the parameters for the script, otherwise defaultdefault values are used.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-cmh, --cm_host</code></p></td>
<td style="text-align: left;"><p><code>127.0.0.1</code></p></td>
<td style="text-align: left;"><p>Specifies the host where Connector Manager is running. This parameter is ignored if the <code>-cm</code> parameter is not provided.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>-cmp, --cm_port</code></p></td>
<td style="text-align: left;"><p><code>9500</code></p></td>
<td style="text-align: left;"><p>Specifies the port where Connector Manager is running. This parameter is ignored if <code>-cm</code> parameter is not provided.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-o, --options</code></p></td>
<td style="text-align: left;"><p><code>no default values</code></p></td>
<td style="text-align: left;"><p>Specifies the JVM options used on when the connector starts. For example, <code>-Xms64M -Xmx1G</code>.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>-tls</code></p></td>
<td style="text-align: left;"><p><code>N/A</code></p></td>
<td style="text-align: left;"><p>Specifies to use HTTPS instead of HTTP. .
When this parameter is used, the configuration file must contain an additional section with the preconfigured paths for the key store and trust store files.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-s, --show</code></p></td>
<td style="text-align: left;"><p><code>N/A</code></p></td>
<td style="text-align: left;"><p>Performs a dry run (does nothing). The output prints the start CLI command and its raw output and exits. This parameter is useful to check your parameters without running the connector.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>-b, --background</code></p></td>
<td style="text-align: left;"><p><code>N/A</code></p></td>
<td style="text-align: left;"><p>Runs the connector in the background. No logs are shown and the connector continues running in detached mode.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>-h, --help</code></p></td>
<td style="text-align: left;"><p><code>N/A</code></p></td>
<td style="text-align: left;"><p>Prints the help information and exits.</p></td>
</tr>
</tbody>
</table>

Script also provides that help information from command line using parameter `-h`.

More configuration example of starting Connector together with Connector Manager are provided by the Connector Manager samples.

### Quick Start: Running the connector as a Container

The following steps show how to use the sample docker compose file that has been included in the package:

1.  Change to the `docker` directory:

        cd samples/docker

    This directory contains both the `docker-compose.yml` file as well as an `.env` file that contains environment secrets required for the container’s health check.

2.  Run the connector:

        docker-compose up -d

    This sample docker compose file will:

    -   Exposes the connector’s `8090` web port to `8090` on the host.

    -   Connects a PubSub+ event broker and File exposed on the host using default ports.

    -   Mounts the `samples/config` directory.

    -   Mounts the previously defined `libs` directory.

    -   Creates a `healthcheck` user with read-only permissions.

        -   The default username and password for this user can be found within the `.env` file.

        -   This user overrides any users you have defined in your `application.yml`. See [here] for more information.

    -   Uses the connector’s management health endpoint as the container’s health check.

For more information about how to use and configure this container, see [the connector’s container documentation].

## Enabling Workflows

The provided `application.yml` enables workflow 0 and 1. To enable additional workflows, define the following properties in the `application.yml`, where `<workflow-id>` is a value between `[0-19]`:

    spring:
      cloud:
        stream:
          bindings: # Workflow bindings
            input-<workflow-id>:
              destination: <input-destination> # Queue name
              binder: (solace|file) # Input system
            output-<workflow-id>:
              destination: <output-destination> # Topic name
              binder: (solace|file) # Output system

    solace:
      connector:
        workflows:
          <workflow-id>:
            enabled: true

> **NOTE**
> 
> The connector only supports workflows in the directions of:
> 
> -   `solace` → `File`
> 
> -   `File` → `solace`

For more information about Spring Cloud Stream and the Solace PubSub+ binder, see:

-   [Spring Cloud Stream Reference Guide]

-   [Spring Cloud Stream Binder for Solace PubSub+]

## Configuring Connection Details

### Solace PubSub+ Connection Details

The Spring Cloud Stream Binder for PubSub+ uses [Spring Boot Auto-Configuration for the Solace Java API ] to configure its session.

In the `application.yml`, this typically is configured as follows:

    solace:
      java:
        host: tcp://localhost:55555
        msg-vpn: default
        client-username: default
        client-password: default

For more information and options to configure the PubSub+ session, see [Spring Boot Auto-Configuration for the Solace Java API][3].

#### Preventing Message Loss when Publishing to Topic-to-Queue Mappings

If the connector is publishing to a topic that is subscribed to by a queue, messages may be lost if they are rejected. For example, if queue ingress is shutdown.

To prevent message loss, configure [`reject-msg-to-sender-on-discard` with the `including-when-shutdown`] flag.

### Connecting to Multiple Systems

To connect to multiple systems of a same type, use the [multiple binder syntax].

For example:

    spring:
      cloud:
        stream:
          binders:

            # 1st solace binder in this example
            solace1:
              type: solace
              environment:
                solace:
                  java:
                    host: tcp://localhost:55555

            # 2nd solace binder in this example
            solace2:
              type: solace
              environment:
                solace:
                  java:
                    host: tcp://other-host:55555

            # The only file binder
            file1:
              type: file
              # Add `environment` property map here if you need to customize this binder.
              # But for this example, we'll assume that defaults are used.

            # Required for internal use
            undefined:
              type: undefined
          bindings:
            input-0:
              destination: <input-destination>
              binder: file1
            output-0:
              destination: <output-destination>
              binder: solace1 # Reference 1st solace binder
            input-1:
              destination: <input-destination>
              binder: file1
            output-1:
              destination: <output-destination>
              binder: solace2 # Reference 2nd solace binder

The configuration above defines two binders of type `solace` and one binder of type `file`, which are then referenced within bindings.

Each binder above is configured independently under `spring.cloud.stream.binders.<binder-name>.environment`.

> **IMPORTANT**
> 
> -   When connecting to multiple systems, all binder configuration must be specified using the multiple binder syntax for all binders. For example, under the `spring.cloud.stream.binders.<binder-name>.environment`.
> 
> -   Do not use single-binder configuration (for example, `solace.java.*` at the root of your `application.yml`) while using the multiple binder syntax.

include::../../../snippets/attributes/common.adoc

#### File Source Connection Details

The Spring Cloud Stream Binder for File uses the following configuration to configure Source Connector

    spring:
      cloud:
        stream:
          bindings:
            input-0:
              destination: # Absolute file path of source and sink file/directory. In general for Static, Directory replication we need to configure source and sink paths in a separate config file since multiple files and directories are supported, provide the absolute location of config file(Create a file with extension .cfg and add your path as per format at the end. Each line represents a source and sink path). In case of dynamic file we can configure the source and sink path without the need for separate config file since only one dynamic file is supported for replication.
              # Format to configure file location(absolute-source-file-path|absolute-sink-filepath). This format applies for Static, Directory and Dynamic files.
              binder: file
            output-0:
              destination: # configure solace topic - File events are published to this topic. This topic should be added as subscription to Sink Connector queue
              binder: solace

include::../../../snippets/attributes/common.adoc

#### File Sink Connection Details

The Spring Cloud Stream Binder for File uses the following configuration to configure Sink Connector

    spring:
      cloud:
        stream:
          bindings:
            output-0:
              destination: # Absolute base destination path of Sink file or directory. This value is used when dest_file_name_type property is set to 1, 4 or 5
              binder: file
            input-0:
              destination: # configure sink connector queue where file events sent by source connector are spooled
              binder: solace

## User-configured Header Transforms

Generally, the consumed message’s headers are propagated through the connector to the output message. If you want to transform the headers, then you can do so as follows:

    # <workflow-id> : The workflow ID ([0-19])
    # <header> : The key for the outbound header
    # <expression> : A SpEL expression which has "headers" as parameters

    solace.connector.workflows.<workflow-id>.transform-headers.expressions.<header>=<expression>

**Example 1:** To create a new header, `new_header`, for workflow `0` that is derived from the headers `foo` & `bar`:

    solace.connector.workflows.0.transform-headers.expressions.new_header="T(String).format('%s/abc/%s', headers.foo, headers.bar)"

**Example 2:** To remove the header, `delete_me`, for workflow `0`, set the header transform expression to `null`:

    solace.connector.workflows.0.transform-headers.expressions.delete_me="null"

For more information about Spring Expression Language (SpEL) expressions, see [Spring Expression Language (SpEL)].

## User-configured Payload Transforms

Message payloads going through a workflow can be transformed using a Spring Expression Language (SpEL) expression as follows:

    # <workflow-id> : The workflow ID ([0-19])
    # <expression> : A SpEL expression

    solace.connector.workflows.<workflow-id>.transform-payloads.expressions[0].transform=<expression>

A SpEL expression may reference:

-   `payload`: To access the message payload.

-   `headers.<header_name>`: To access a message header value.

-   Registered functions.

> **NOTE**
> 
> While the syntax uses an array of expressions, only a single transform expression is supported in this release. Multiple transform expressions may be supported in the future.

### Registered Functions

[Registered functions][4] are built-in and can be called directly from SpEL expressions. To call a registered function, use the `#` character followed by the function name. The following table describes the available registered functions:

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Registered Function Signature</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>boolean isPayloadBytes(Object obj)</code></p></td>
<td style="text-align: left;"><p>Returns whether the object <code>obj</code> is an instance of <code>byte[]</code> or not.</p>
<p>Sample usage of this function within a SpEL expression: <code>"#isPayloadBytes(payload) ? true : false"</code></p></td>
</tr>
</tbody>
</table>

**Example 1:** To normalize `byte[]` and `String` payloads as upper-cased `String` payloads or leave payloads unchanged when of different types:

    solace.connector.workflows.0.transform-payloads.expressions[0].transform="#isPayloadBytes(payload) ? new String(payload).toUpperCase() : payload instanceof T(String) ? payload.toUpperCase() : payload"

**Example 2:** To convert `String` payloads to `byte[]` payloads using a `charset` retrieved from a message header or leave payloads unchanged when of different types:

    solace.connector.workflows.0.transform-payloads.expressions[0].transform="payload instanceof T(String) ? payload.getBytes(T(java.nio.charset.Charset).forName(headers.charset)) : payload"

For more information about Spring Expression Language (SpEL) expressions, see [Spring Expression Language (SpEL)].

## Message Headers

Solace and file headers can be created or manipulated using the [User-configured Header Transforms][5] feature described above.

### Solace Headers

Solace headers exposed to the connector are documented in the [Spring Cloud Stream Binder for Solace PubSub+][6] documentation.

### Reserved Message Headers

The following are reserved header spaces:

-   `solace_`

-   `scst_`

-   Any headers defined by the core Spring messaging framework. See [Spring Integration: Message Headers] for more info.

Any headers with these prefixes (that are not defined by the connector or any technology used by the connector) may not be backwards compatible in future releases of this connector.

## Management and Monitoring Connector

### Monitoring Connector’s States

The connector provides an ability to monitor its internal states through exposed endpoints provided by [Spring Boot Actuator].

An Actuator shares information through the endpoints reachable over HTTP/HTTPS. The endpoints that are available are configured in the connector configuration file.

What endpoints are available is configured in the connector configuration file:

    management:
      simple:
        metrics:
          export:
            enabled: true
      endpoints:
        web:
          exposure:
            include: "health,metrics,loggers,logfile,channels,env,workflows,leaderelection,bindings,info"

The above sample configuration enables metrics collection through the configuration parameter of `management.simple.metrics.export.enabled` set to `true` and then shares them through the HTTP/HTTPS endpoint together with other sections configured for the current connector.

#### Exposed HTTP/HTTPS Endpoints

The set of endpoints exposed through the HTTP/HTTPS endpoint.

-   Exposed endpoints are available if you query the endpoints using the web interface (for example `https://localhost:8090/actuator/<some_endpoint>`) and also available in PubSub+ Connector Manager.

-   The operator may choose to not expose all or some of these endpoints. If so, the Actuator endpoints that are not exposed are not visible if you query the endpoints (for example, `https://localhost:8090/actuator/<some_endpoint>`) nor in PubSub+ Connector Manager.

> **NOTE**
> 
> The simple metrics registry is only to be used for testing. It is not a production-ready means of collecting metrics. In production, use a dedicated monitoring system (for example, Datadog, Prometheus, etc.) to collect metrics.

The Actuator endpoint now contains information about Connector’s internal states shared over the following HTTP/HTTPS endpoint:

    GET: /actuator/

The following shows an example of the data shared with the configuration above:

    {
      "_links": {
        "self": {
          "href": "/actuator",
          "templated": false
        },
        "workflows": {
          "href": "/actuator/workflows",
          "templated": false
        },
        "workflows-workflowId": {
          "href": "/actuator/workflows/{workflowId}",
          "templated": true
        },
        "leaderelection": {
          "href": "/actuator/leaderelection",
          "templated": false
        },
        "health-path": {
          "href": "/actuator/health/{*path}",
          "templated": true
        },
        "health": {
          "href": "/actuator/health",
          "templated": false
        },
        "metrics": {
          "href": "/actuator/metrics",
          "templated": false
        },
        "metrics-requiredMetricName": {
          "href": "/actuator/metrics/{requiredMetricName}",
          "templated": true
        }
      }
    }

## Health

The connector reports its health status using the [Spring Boot Actuator health endpoint].

To configure the information returned by the `health` endpoint, configure the following properties:

-   `management.endpoint.health.show-details`

-   `management.endpoint.health.show-components`

For more information, about health endpoints, see [Spring Boot documentation].

Health for the workflow, Solace binder, and file binder components are exposed when `management.endpoint.health.show-components` is enabled. For example:

    management:
      endpoint:
       health:
        show-components: always
        show-details: always

This configuration would always show the full details of the health check including the workflows and binders. The default value is `never`.

### Workflow Health

A `workflows` health indicator is provided to show the health status for each of a connector’s workflows. This health indicator has the following form:

    {
      "status": "(UP|DOWN)",
      "components": {
        "<workflow-id>": {
          "status": "(UP|DOWN)",
          "details": {
            "error": "<error message>"
          }
        }
      }
    }

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 75%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Health Status</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>UP</code></p></td>
<td style="text-align: left;"><p>A status that indicates the workflow is functioning as expected.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>DOWN</code></p></td>
<td style="text-align: left;"><p>A status that indicates the workflow is unhealthy. Operator intervention may be required.</p></td>
</tr>
</tbody>
</table>

![Workflow Health Resolution Diagram]

This health indicator is enabled default. To disable it, set the property as follows:

    management.health.workflows.enabled=false

### Solace Binder Health

For details, see the [Solace binder] documentation.

## Leader Election

The connector has three leader election modes for redundancy:

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 75%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Leader Election Mode</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>Standalone (Default)</p></td>
<td style="text-align: left;"><p>A single instance of a connector without any leader election capabilities.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>Active-Active</p></td>
<td style="text-align: left;"><p>A participant in a cluster of connector instances where all instances are active.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>Active-Standby</p></td>
<td style="text-align: left;"><p>A participant in a cluster of connector instances where only one instance is active (i.e. the leader), and the others are standby.</p></td>
</tr>
</tbody>
</table>

Operators can configure the leader election mode by setting the following configuration:

    solace.connector.management.leader-election.mode=(standalone|active_active|active_standby)

### Leader Election Modes: Standalone / Active-Active

When the connector starts, all enabled workflows start at the same time. The connector itself is considered as always active.

### Leader Election Mode: Active-Standby

If the connector is in active-standby mode, a PubSub+ management session and management queue must be configured as follows:

    solace.connector.leader-election.mode=active_standby

    # Management session
    # Exact same interface as solace.java.*
    solace.connector.management.session.host=<management-host>
    solace.connector.management.session.msgVpn=<management-vpn>
    solace.connector.management.session.client-username=<client-username>
    solace.connector.management.session.client-password=<client-password>
    solace.connector.management.session.<other-property-name>=<value>

    # Management queue name accessible by the management session
    # Must have exclusive access type
    solace.connector.management.queue=<management-queue-name>

To determine if the connector is `active` or `standby`, it creates a flow to the management queue. If this flow is active, then the connector’s state is `active` and will start its enabled workflows. Otherwise, if this flow is inactive, then the connector’s state is `standby` and will stop its enabled workflows.

At a macro level for a cluster of connectors, failover only happens when there are infrastructure failures (for example, the JVM goes down or networking failures to the management queue).

IIf a workflow fails to start or stop during failover, it will retry up to some maximum defined by the configuration option, `solace.connector.management.leader-election.fail-over.max-attempts`.

During failover, the connector attempts to start or stop all enabled workflows. After an attempt has been made to start or stop each workflow, the connector transitions to the active/standby mode regardless of the status of the workflows.

### Leader Election Management Endpoint

A custom `leaderelection` management endpoint was provided using [Spring Actuator].

Operators can navigate to the connector’s `leaderelection` management endpoint to view its leader election status.

<table>
<colgroup>
<col style="width: 28%" />
<col style="width: 14%" />
<col style="width: 57%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Endpoint</th>
<th style="text-align: left;">Operation</th>
<th style="text-align: left;">Payloads</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>/leaderelection</code></p></td>
<td style="text-align: left;"><p>Read<br />
(HTTP <code>GET</code>)</p></td>
<td style="text-align: left;"><p><strong>Request:</strong> None.</p>
<p><strong>Response:</strong></p>
<div class="sourceCode" id="cb1"><pre class="sourceCode json"><code class="sourceCode json"><span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a><span class="fu">{</span></span>
<span id="cb1-2"><a href="#cb1-2" aria-hidden="true" tabindex="-1"></a>  <span class="dt">&quot;mode&quot;</span><span class="fu">:</span> <span class="fu">{</span></span>
<span id="cb1-3"><a href="#cb1-3" aria-hidden="true" tabindex="-1"></a>    <span class="dt">&quot;type&quot;</span><span class="fu">:</span> <span class="st">&quot;(standalone |</span></span>
<span id="cb1-4"><a href="#cb1-4" aria-hidden="true" tabindex="-1"></a><span class="st">             active_active |         </span></span>
<span id="cb1-5"><a href="#cb1-5" aria-hidden="true" tabindex="-1"></a><span class="st">             active_standby)&quot;</span><span class="fu">,</span></span>
<span id="cb1-6"><a href="#cb1-6" aria-hidden="true" tabindex="-1"></a>    <span class="dt">&quot;state&quot;</span><span class="fu">:</span> <span class="st">&quot;(active | standby)&quot;</span><span class="fu">,</span>     </span>
<span id="cb1-7"><a href="#cb1-7" aria-hidden="true" tabindex="-1"></a>    <span class="dt">&quot;source&quot;</span><span class="fu">:</span> <span class="fu">{</span>                      </span>
<span id="cb1-8"><a href="#cb1-8" aria-hidden="true" tabindex="-1"></a>      <span class="dt">&quot;queue&quot;</span><span class="fu">:</span> <span class="st">&quot;&lt;management-queue-name&gt;&quot;</span><span class="fu">,</span></span>
<span id="cb1-9"><a href="#cb1-9" aria-hidden="true" tabindex="-1"></a>      <span class="dt">&quot;host&quot;</span><span class="fu">:</span> <span class="st">&quot;&lt;management-host&gt;&quot;</span><span class="fu">,</span></span>
<span id="cb1-10"><a href="#cb1-10" aria-hidden="true" tabindex="-1"></a>      <span class="dt">&quot;msgVpn&quot;</span><span class="fu">:</span> <span class="st">&quot;&lt;management-vpn&gt;&quot;</span></span>
<span id="cb1-11"><a href="#cb1-11" aria-hidden="true" tabindex="-1"></a>    <span class="fu">}</span></span>
<span id="cb1-12"><a href="#cb1-12" aria-hidden="true" tabindex="-1"></a>  <span class="fu">}</span></span>
<span id="cb1-13"><a href="#cb1-13" aria-hidden="true" tabindex="-1"></a><span class="fu">}</span></span></code></pre></div>
<ul>
<li><p>Mandatory parameter in output</p></li>
<li><p>Mandatory parameter in output</p></li>
<li><p>Optional section. Appears only when <code>type</code> is set to <code>active_standby</code>.</p></li>
</ul></td>
</tr>
</tbody>
</table>

## Workflow Management

### Workflow Management Endpoint

A custom `workflows` management endpoint using [Spring Actuator] is provided to manage workflows.

To enable the `workflows` management endpoint:

    management:
      endpoints:
        web:
          exposure:
            include: "workflows"

Once the `workflows` management endpoint is enabled, the following operations can be performed:

<table>
<colgroup>
<col style="width: 28%" />
<col style="width: 14%" />
<col style="width: 57%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Endpoint</th>
<th style="text-align: left;">Operation</th>
<th style="text-align: left;">Payloads</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>/workflows</code></p></td>
<td style="text-align: left;"><p>Read<br />
(HTTP <code>GET</code>)</p></td>
<td style="text-align: left;"><p><strong>Request:</strong> None.</p>
<p><strong>Response:</strong><br />
Same payload as the <code>/workflows/{workflowId}</code> read operation, but as a list of all workflows.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>/workflows/{workflowId}</code></p></td>
<td style="text-align: left;"><p>Read<br />
(HTTP <code>GET</code>)</p></td>
<td style="text-align: left;"><p><strong>Request:</strong> None.</p>
<p><strong>Response:</strong></p>
<div class="sourceCode" id="cb1"><pre class="sourceCode json"><code class="sourceCode json"><span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a><span class="fu">{</span></span>
<span id="cb1-2"><a href="#cb1-2" aria-hidden="true" tabindex="-1"></a>  <span class="dt">&quot;id&quot;</span><span class="fu">:</span> <span class="st">&quot;&lt;workflowId&gt;&quot;</span><span class="fu">,</span></span>
<span id="cb1-3"><a href="#cb1-3" aria-hidden="true" tabindex="-1"></a>  <span class="dt">&quot;enabled&quot;</span><span class="fu">:</span> <span class="er">(</span><span class="kw">true</span><span class="er">|</span><span class="kw">false</span><span class="er">)</span><span class="fu">,</span></span>
<span id="cb1-4"><a href="#cb1-4" aria-hidden="true" tabindex="-1"></a>  <span class="dt">&quot;state&quot;</span><span class="fu">:</span> <span class="st">&quot;(running|stopped|paused|unknown)&quot;</span><span class="fu">,</span></span>
<span id="cb1-5"><a href="#cb1-5" aria-hidden="true" tabindex="-1"></a>  <span class="dt">&quot;inputBindings&quot;</span><span class="fu">:</span> <span class="ot">[</span></span>
<span id="cb1-6"><a href="#cb1-6" aria-hidden="true" tabindex="-1"></a>    <span class="st">&quot;&lt;input-binding&gt;&quot;</span></span>
<span id="cb1-7"><a href="#cb1-7" aria-hidden="true" tabindex="-1"></a>  <span class="ot">]</span><span class="fu">,</span></span>
<span id="cb1-8"><a href="#cb1-8" aria-hidden="true" tabindex="-1"></a>  <span class="dt">&quot;outputBindings&quot;</span><span class="fu">:</span> <span class="ot">[</span></span>
<span id="cb1-9"><a href="#cb1-9" aria-hidden="true" tabindex="-1"></a>    <span class="st">&quot;&lt;output-binding&gt;&quot;</span></span>
<span id="cb1-10"><a href="#cb1-10" aria-hidden="true" tabindex="-1"></a>  <span class="ot">]</span></span>
<span id="cb1-11"><a href="#cb1-11" aria-hidden="true" tabindex="-1"></a><span class="fu">}</span></span></code></pre></div></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>/workflows/{workflowId}</code></p></td>
<td style="text-align: left;"><p>Write<br />
(HTTP <code>POST</code>)</p></td>
<td style="text-align: left;"><p><strong>Request:</strong></p>
<div class="sourceCode" id="cb2"><pre class="sourceCode json"><code class="sourceCode json"><span id="cb2-1"><a href="#cb2-1" aria-hidden="true" tabindex="-1"></a><span class="fu">{</span></span>
<span id="cb2-2"><a href="#cb2-2" aria-hidden="true" tabindex="-1"></a><span class="dt">&quot;state&quot;</span><span class="fu">:</span> <span class="st">&quot;STARTED|STOPPED|PAUSED|RESUMED&quot;</span></span>
<span id="cb2-3"><a href="#cb2-3" aria-hidden="true" tabindex="-1"></a><span class="fu">}</span></span></code></pre></div>
<p><strong>Response:</strong> None.</p></td>
</tr>
</tbody>
</table>

> **NOTE**
> 
> Only workflows with Solace PubSub+ consumers (where the `solace` binder is defined in the `input-#`) support pause/resume.
> **NOTE**
> 
> Some features require for the connector to manage workflow lifecycles. There's no guarantee that workflow states continue to persist when write operations are used to change the workflow states while such features are in use.
> 
> For example: When the connector is configured in the active-standby leader election mode, workflows will automatically transition from `running` to `stopped` when the connector fails over from `active` to `standby`. Vice-versa for a failover in the opposite direction.

### Workflow States

A workflow’s state is defined as the aggregate states of its bindings (see the [`bindings` management endpoint]) as follows:

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 66%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Workflow State</th>
<th style="text-align: left;">Condition</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>running</code></p></td>
<td style="text-align: left;"><p>All bindings have <code>state="running"</code>.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>stopped</code></p></td>
<td style="text-align: left;"><p>All bindings have <code>state="stopped"</code>.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>paused</code></p></td>
<td style="text-align: left;"><p>All consumer bindings and all pausable producer bindings have <code>state="paused"</code>.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>unknown</code></p></td>
<td style="text-align: left;"><p>None of the other states. Represents an inconsistent aggregate binding state.</p></td>
</tr>
</tbody>
</table>

> **NOTE**
> 
> When the producer or consumer binding is not implementing Spring's Lifecycle interface, Spring always reports the bindings as `state=N/A`. The `state=N/A` is ignored when deciding the overall state of the workflow. For example, if the consumer's binding is `state=running` and producer's binding `state=N/A` (or vise-versa), the workflow state would be `running`.

For more information about binding states, see [Spring Cloud Stream: Binding visualization and control][`bindings` management endpoint].

## Metrics

This connector uses [Spring Boot Metrics] that leverages Micrometer to manage its metrics.

### Connector Meters

In addition to the meters already provided by the Spring framework, this connector introduces the following custom meters:

<table>
<colgroup>
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Name</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Tags</th>
<th style="text-align: left;">Description</th>
<th style="text-align: left;">Notes</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>solace.connector.process</code></p></td>
<td style="text-align: left;"><p><code>Timer</code></p></td>
<td style="text-align: left;"><p><code>type: channel</code></p>
<p><code>name: &lt;bindingName&gt;</code></p>
<p><code>result: (success|failure)</code></p>
<p><code>exception: (none|exception simple class name)</code></p></td>
<td style="text-align: left;"><p>The processing time.</p></td>
<td style="text-align: left;"><p>This meter is a rename of <a href="https://docs.spring.io/spring-integration/docs/current/reference/html/system-management.html#overview"><code>spring.integration.send</code></a> whose <code>name</code> tag matches a binding name.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>solace.connector.error.process</code></p></td>
<td style="text-align: left;"><p><code>Timer</code></p></td>
<td style="text-align: left;"><p><code>type: channel</code></p>
<p><code>name: &lt;bindingNames&gt;</code></p>
<p><code>result: (success|failure)</code></p>
<p><code>exception: (none|exception simple class name)</code></p></td>
<td style="text-align: left;"><p>The error processing time.</p></td>
<td style="text-align: left;"><p>This meter is a rename of <a href="https://docs.spring.io/spring-integration/docs/current/reference/html/system-management.html#overview"><code>spring.integration.send</code></a> whose <code>name</code> tag matches an input binding’s error channel name (<code>&lt;destination&gt;.&lt;group&gt;.errors</code>).</p>
<p>Meters might be merged under the same <code>name</code> tag (delimited by <code>|</code>) if multiple bindings have the same error channel name (for example, bindings can have a matching <code>destination</code>, <code>group</code>, or both). <strong>NOTE: Setting a binding’s <code>group</code> is not supported.</strong></p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>solace.connector.message.size.payload</code></p></td>
<td style="text-align: left;"><p><code>DistributionSummary</code></p>
<p>Base Units: <code>bytes</code></p></td>
<td style="text-align: left;"><p><code>name: &lt;bindingName&gt;</code></p></td>
<td style="text-align: left;"><p>The message payload size.</p></td>
<td style="text-align: left;"></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>solace.connector.message.size.total</code></p></td>
<td style="text-align: left;"><p><code>DistributionSummary</code></p>
<p>Base Units: <code>bytes</code></p></td>
<td style="text-align: left;"><p><code>name: &lt;bindingName&gt;</code></p></td>
<td style="text-align: left;"><p>The total message size.</p></td>
<td style="text-align: left;"></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>solace.connector.publish.ack</code></p></td>
<td style="text-align: left;"><p><code>Counter</code></p>
<p>Base Units: <code>acknowledgments</code></p></td>
<td style="text-align: left;"><p><code>name: &lt;bindingName&gt;</code></p>
<p><code>result: (success|failure)</code></p>
<p><code>exception: (none|exception simple class name)</code></p></td>
<td style="text-align: left;"><p>The publish acknowledgment count.</p></td>
<td style="text-align: left;"></td>
</tr>
</tbody>
</table>

> **IMPORTANT**
> 
> The `solace.connector.process` meter with `result=failure` is not a reliable measure of tracking the number of failed messages. It only tells you how many times a step processed a message (or batch of messages), how long it took to process that message, and if that step completed successfully.
> 
> Instead, we recommend that you use a combination of `solace.connector.error.process` and `solace.connector.publish.ack` to track failed messages.

### Add a Monitoring System

By default, this connector includes the following monitoring systems:

-   [Datadog]

-   [Dynatrace]

-   [Influx]

-   [JMX]

-   [OpenTelemetry (OTLP)]

-   [StatsD]

To add additional monitoring systems, add the system’s `micrometer-registry-<system>` JAR file and its dependency JAR files to [the connector’s classpath]. The included systems can then be individually enabled/disabled by setting `management.<system>.metrics.export.enabled=true` in the `application.yml`.

## Security

### Securing Endpoints

#### Exposed Management Web Endpoints

There are many endpoints that are automatically enabled for this connector. For a comprehensive list, see [Management and Monitoring Connector][7].

The `health` endpoint only returns the root status by default (i.e. no health details).

To enable other management endpoints, see [Spring Actuator Endpoints][Spring Actuator].

#### Authentication & Authorization

This release of the connector only supports basic HTTP authentication.

By default, no users are created unless the operator configures them in their configuration file. The configuration parameters responsible for security are as follows:

    solace:
      connector:
        security:
          enabled: true
          users:
          - name: user1
            password: pass
          - name: admin1
            password: admin
            roles:
            - admin

In the above example, we have created two users:

-   **user1**: Has access to perform GET (Read) requests.

-   **admin1**: Has access to perform GET and POST (Read & Write) requests.

To fully disable security and permit anyone to access the connector’s web endpoints, operators can configure the `solace.connector.security.enabled` parameter `false`.

> **IMPORTANT**
> 
> While these properties could be defined in an `application.yml` file, we recommend that you use environment variables to set secret values.

The following example shows you how to define users using environment variables:

    # Create user with no role (i.e. read-only)
    SOLACE_CONNECTOR_SECURITY_USERS_0_NAME=user1
    SOLACE_CONNECTOR_SECURITY_USERS_0_PASSWORD=pass

    # Create user with admin role
    SOLACE_CONNECTOR_SECURITY_USERS_1_NAME=admin1
    SOLACE_CONNECTOR_SECURITY_USERS_1_PASSWORD=admin
    SOLACE_CONNECTOR_SECURITY_USERS_1_ROLES_0=admin

In the above example, we have created two users:

-   **user1**: Has access to perform GET (Read) requests.

-   **admin1**: Has access to perform GET and POST (Read & Write) requests.

> **NOTE**
> 
> `solace.connector.security.users` is a list. When users are defined in multiple sources (different `application.yml` files, environment variables, and so on), overriding works by replacing the entire list. In other words, you must pick one place to define all your users, whehter in a **single** application properties file or as environment variables.
> 
> For more information, see [Spring Boot - Merging Complex Types].
> 
>   [Spring Boot - Merging Complex Types]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.typesafe-configuration-properties.merging-complex-types

#### TLS

TLS is disabled by default.

To configure TLS, see [Spring Boot - Configure SSL] and [TLS Setup in Spring].

## Consuming Object Messages

For the connector to process object messages, it needs access to the classes which define the object payloads.

Assuming that your payload classes are in their own project(s) and are packaged into their own jar(s), place these jar(s) and their dependencies (if any) onto [the connector’s classpath].

> **TIP**
> 
> It is recommended that these jars only contain the relevant payload classes to prevent any oddities.
> **TIP**
> 
> In the jar(s), your class files must be archived in the same directory/classpath as the application that publishes them.
> 
> e.g. If the source application is publishing a message with payload type, `MySerializablePayload`, defined under classpath `com.sample.payload`, then when packaging the payload jar for the connector, the `MySerializablePayload` class must still be accessible under the `com.sample.payload` classpath.
> 
> Typically, build tools such as Maven or Gradle will handle this when packaging jars.

## Adding External Libraries

The connector jar uses the `loader.path` property as the recommended mechanism for adding external libraries to the connector’s classpath.

See [Spring Boot - PropertiesLauncher Features] for more info.

To add libraries to the connector’s container image, see [the connector’s container documentation].

## Configuration

### Providing Configuration

For information about about how the connector detects configuration properties, see [Spring Boot: Externalized Configuration].

#### Converting Canonical Spring Property Names to Environment Variables

For information about converting the Spring property names to environment variables, see the [Spring documentation].

#### Spring Profiles

If multiple configuration files exist within the same configuration directory for use in different environments (development, production, etc.), use Spring profiles.

Using Spring profiles allow you to define different application property files under the same directory using the filename format, `application-{profile}.yml`.

For example:

-   `application.yml`: The properties in non-specific files that always apply. Its properties are overridden by the properties defined in profile-specific files.

-   `application-dev.yml`: Defines properties specific to the development environment.

-   `application-prod.yml`: Defines properties specific to the production environment.

Individual profiles can then be enabled by setting the `spring.profiles.active` property.

See [Spring Boot: Profile-Specific Files] for more information and an example.

#### Configure Locations to Find Spring Property Files

By default, the connector detects any Spring property files as described in the [Spring Boot’s default locations].

-   If you want to add additional locations, add `--spring.config.additional-location=file:<custom-config-dir>` (This parameter is similar to the example command in [Quick Start: Running the connector via command line][8]).

-   If you want to exclusively use the locations that you’ve defined and ignore Spring Boot’s default locations, add `--spring.config.location=optional:classpath:/,optional:classpath:/config/,file:<custom-config-dir>`.

For more information about configuring locations to find Sprint property files, see [Spring Boot documentation][Spring Boot’s default locations].

> **TIP**
> 
> If you want configuration files for multiple, different connectors within the same `config` directory for use in different environments (such as development, production, etc.), we recommend that you use [Spring Boot Profiles] instead of child directories. For example:
> 
> -   Set up your configuration like this:
> 
>     -   `config/application-prod.yml`
> 
>     -   `config/application-dev.yml`
> 
> -   Do not do this:
> 
>     -   `config/prod/application.yml`
> 
>     -   `config/dev/application.yml`
> 
> Child directories are intended to be used for merging configuration from multiple sources of configuration properties. For more information and an example of when you might want to use multiple child directories to compose your application's configuration, see the [Spring Boot documentation].
> 
>   [Spring Boot Profiles]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files.profile-specific
>   [Spring Boot documentation]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files.wildcard-locations

#### Obtaining Build Information

Build information, including version, build date, time and description is enabled by default via [Spring Boot Actuator Info Endpoint]. By default, every connector shares all information related to its [build] only.

Below is the structure of the output data:

    {
      "build": {
        "version": "<connector version>",
        "artifact": "<connector artifact>",
        "name": "<connector name>",
        "time": "<connector build time>",
        "group": "<connector group>",
        "description": "<connector description>",
        "support": "<support information>"
      }
    }

If you want to exclude build data from the output of the `info` endpoint, set `management.info.build.enabled` to `false`.

Alternatively, if you want to disable the info endpoint entirely, you can remove 'info' from the list of endpoints specified in `management.endpoints.web.exposure.include`.

### Spring Configuration Options

This connector packages many libraries for you to customize functionality. Here are some references to get started:

-   [Spring Cloud Stream]

-   [Spring Cloud Stream Binder for Solace PubSub+][9]

-   [Spring Logging]

-   [Spring Actuator Endpoints][Spring Actuator]

-   [Spring Metrics][Spring Boot Metrics]

### Connector Configuration Options

he following table lists the configuration options. The following options in **Config Option** are prefixed with `solace.connector.`:

<table>
<colgroup>
<col style="width: 28%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 28%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>management.leader-election.fail-over.max-attempts</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>&gt; 0</code></p></td>
<td style="text-align: left;"><p><code>3</code></p></td>
<td style="text-align: left;"><p>The maximum number of attempts to perform a fail-over.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>management.leader-election.fail-over.back-off-initial-interval</code></p></td>
<td style="text-align: left;"><p><code>long</code></p></td>
<td style="text-align: left;"><p><code>&gt; 0</code></p></td>
<td style="text-align: left;"><p><code>1000</code></p></td>
<td style="text-align: left;"><p>The initial interval (milliseconds) to back-off when retrying a fail-over.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>management.leader-election.fail-over.back-off-max-interval</code></p></td>
<td style="text-align: left;"><p><code>long</code></p></td>
<td style="text-align: left;"><p><code>&gt; 0</code></p></td>
<td style="text-align: left;"><p><code>10000</code></p></td>
<td style="text-align: left;"><p>The maximum interval (milliseconds) to back-off when retrying a fail-over.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>management.leader-election.fail-over.back-off-multiplier</code></p></td>
<td style="text-align: left;"><p><code>double</code></p></td>
<td style="text-align: left;"><p><code>&gt;= 1.0</code></p></td>
<td style="text-align: left;"><p><code>2.0</code></p></td>
<td style="text-align: left;"><p>The multiplier to apply to the back-off interval between each retry of a fail-over.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>management.leader-election.mode</code></p></td>
<td style="text-align: left;"><p><code>enum</code></p></td>
<td style="text-align: left;"><p><code>(standalone|active_active|active_standby)</code></p></td>
<td style="text-align: left;"><p><code>standalone</code></p></td>
<td style="text-align: left;"><p>The connector’s leader election mode.</p>
<p><strong>standalone:</strong><br />
A single instance of a connector without any leader election capabilities.</p>
<p><strong>active_active:</strong><br />
A participant in a cluster of connector instances where all instances are active.</p>
<p><strong>active_standby:</strong><br />
A participant in a cluster of connector instances where only one instance is active (i.e. the leader), and the others are standby.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>management.queue</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>null</code></p></td>
<td style="text-align: left;"><p>The management queue name.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>management.session.*</code></p></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"><p><code>See Spring Boot Auto-Configuration for the Solace Java API</code></p></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"><p>Defines the management session. This has the same interface as that used by <code>solace.java.*</code>.</p>
<p>See <a href="https://github.com/SolaceProducts/solace-spring-boot/tree/master/solace-spring-boot-starters/solace-java-spring-boot-starter#updating-your-application-properties">Spring Boot Auto-Configuration for the Solace Java API</a> for more info.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>security.enabled</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>(true|false)</code></p></td>
<td style="text-align: left;"><p><code>true</code></p></td>
<td style="text-align: left;"><p>If <code>true</code>, security is enabled. Otherwise, anyone has access to the connector’s endpoints.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>security.users[&lt;index&gt;].name</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>null</code></p></td>
<td style="text-align: left;"><p>The name of the user.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>security.users[&lt;index&gt;].password</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>null</code></p></td>
<td style="text-align: left;"><p>The password for the user.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>security.users[&lt;index&gt;].roles</code></p></td>
<td style="text-align: left;"><p><code>list&lt;string&gt;</code></p></td>
<td style="text-align: left;"><p><code>admin</code></p></td>
<td style="text-align: left;"><p><code>empty list (i.e. read-only)</code></p></td>
<td style="text-align: left;"><p>The list of roles that the specified user has. It has read-only access if no roles are returned.</p></td>
</tr>
</tbody>
</table>

### Workflow Configuration Options

These configuration options are defined under the following prefixes:

-   `solace.connector.workflows.<workflow-id>.`: If the options support per-workflow configuration and the default prefixes.

-   `solace.connector.default.workflow.`: If the options support default workflow configuration.

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 25%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Applicable Scopes</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>enabled</code></p></td>
<td style="text-align: left;"><p>Per-Workflow</p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>(true|false)</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>If <code>true</code>, the workflow is enabled.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>transform-headers.expressions</code></p></td>
<td style="text-align: left;"><p>Per-Workflow<br />
Default</p></td>
<td style="text-align: left;"><p><code>Map&lt;string,string&gt;</code></p></td>
<td style="text-align: left;"><p><strong>Key:</strong><br />
A header name.</p>
<p><strong>Value:</strong><br />
A SpEL string that accepts <code>headers</code> as parameters.</p></td>
<td style="text-align: left;"><p><code>empty map</code></p></td>
<td style="text-align: left;"><p>A mapping of header names to header value SpEL expressions.</p>
<p>The SpEL context contains the <code>headers</code> parameter that can be used to read the input message’s headers.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>acknowledgment.publish-async</code></p></td>
<td style="text-align: left;"><p>Per-Workflow<br />
Default</p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>(true|false)</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>If <code>true</code>, publisher acknowledgment processing is done asynchronously.</p>
<p>The workflow’s consumer and producer bindings must support this mode, otherwise the publisher acknowledgments are processed synchronously regardless of this setting.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>acknowledgment.back-pressure-threshold</code></p></td>
<td style="text-align: left;"><p>Per-Workflow<br />
Default</p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p>&gt;= 1</p></td>
<td style="text-align: left;"><p><code>255</code></p></td>
<td style="text-align: left;"><p>The maximum number of outstanding messages with unresolved acknowledgments. Message consumption is paused when the threshold is reached to allow for producer acknowledgments to catch up.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>acknowledgment.publish-timeout</code></p></td>
<td style="text-align: left;"><p>Per-Workflow<br />
Default</p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p>&gt;= -1</p></td>
<td style="text-align: left;"><p><code>600000</code></p></td>
<td style="text-align: left;"><p>The maximum amount of time (in millisecond) to wait for asynchronous publisher acknowledgments before considering a message as failed. A value of <code>-1</code> means to wait indefinitely for publisher acknowledgments.</p></td>
</tr>
</tbody>
</table>

## File Specific Configuration

### File Source Configuration Options

These configuration options are all prefixed by `file.source.`:

<table>
<colgroup>
<col style="width: 28%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 28%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>scheduler.restart_time_sec</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>This property enables source connector to run at periodic intervals. This is needed when you want to replicate your modified files periodically under a directory. Integer value representing number of seconds to wait and start the next replication. Set to Zero if scheduler is not required(Recommended for Dynamic file, since connector first replication runs till EOD is reached). Following is scheduler behaviour w.r.t eod_time_sec</p>
<p>1. restart_time_sec: 10 and eod_time_sec: 104400(5 A.M converted to number of seconds<span class="indexterm" data-primary="24+5)*3600"></span>24+5)*3600 , source connector will stop at 5 A.M</p>
<p>2. restart_time_sec: 10 and eod_time_sec: -1 , source connector will keep on running</p>
<p>3. restart_time_sec: 10 and eod_time_sec: 0 , source connector will exit at midnight</p>
<p>4. restart_time_sec: 0 and eod_time_sec: -1 , source connector will exit after first replication</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.adapter_id</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Unique ID for the connector instance</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.file_type</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>1,2,3,4</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Type of file (1 → static 2 → Dynamic 3 → Directory first level 4 → Directory recursive)</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.state_backup_path</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Absolute file location to store Source Connector’s state information. Only used in case file_to_events is enabled. The file should end in .cfg format(Ex:&lt;path&gt;/source_connector_state_backup.cfg. The file will be created by connector if it doesn’t exist.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.ignoreEmptyFiles</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true, false</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>true → Will ignore the empty files with size 0, false → Empty files will be processed and transferred as normal</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.copy_file_mode_permissions</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0,1</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>When set to 1, this property copies the file permissions in source and sends to sink. Set to 0 if file mode permissions need not be copied</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.max_file_transfer_size</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>999000</code></p></td>
<td style="text-align: left;"><p>Set this value to limit the file size in a replication. Connector will consider the files for replication until the limit is reached</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.max_files_allowed</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>99999</code></p></td>
<td style="text-align: left;"><p>Set this value to limit the number of files in a replication. Connector will consider the files for replication until the limit is reached</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.clear_state_on_eod</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0, 1</code></p></td>
<td style="text-align: left;"><p><code>1</code></p></td>
<td style="text-align: left;"><p>Connector preserves the last successful file state in backup file, so that it resumes from checkpoint on next restart. If this property is set to 1 connector will clear the file state in backup file when End of Day configured time is reached. Set to 0 if file state in backup file need not be cleared</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.eod_time_sec</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>-1,0, any number &gt; 0</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>Connector will exit once configured EOD is elapsed. For example if connector need to be exited every day at 5 A.M EOD should be configured to 104400. The formula to calculate EOD is (24 Hours + (number of hours(24 hour format) when connector should exit))*3600. In our example (24+5)*3600 = 104400. Set this to 0 is connector need to exit at midnight every day and -1 to disable this check</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>file_to_event.enabled</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0,1</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>Set this value to 0 to disable and 1 to enable file to event streaming instead of a file transfer.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>file_to_event.fileFormat</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>1,2,3,4</code></p></td>
<td style="text-align: left;"><p><code>1</code></p></td>
<td style="text-align: left;"><p>1 = Line by line file streaming. 2 = Delimited file streaming. Delimiter can be defined in the parameter eventDelimiter. 3 = JSON File Streaming. 4 = XML File Streaming</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>file_to_event.eventDelimiter</code></p></td>
<td style="text-align: left;"><p><code>Char</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>provide an event Delimiter. Events in the files are separated by this character.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>file_to_event.paramDelimiter</code></p></td>
<td style="text-align: left;"><p><code>String</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>In case the fileFormat values are 1 and 2, use a param Delimiter to map the parameters to headers and create a final json payload. Use with paramHeaderMap</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>file_to_event.paramHeaderMap</code></p></td>
<td style="text-align: left;"><p><code>String</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>provide a header map to create a json payload from a delimited file. Example - 'SNO,Employee_name,Employee_address,city'</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>file_to_event.dynamicTopic</code></p></td>
<td style="text-align: left;"><p><code>String</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>For FileFormats value 1 and 2 use when paramDelimiter is defined. Add dynamic column values of the delimited file in the topic Structure.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>file_to_event.jsonPath</code></p></td>
<td style="text-align: left;"><p><code>String</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>provide a jsonPath filter to stream json objects from a json file. Use with fileFormat value 3 i.e. JSON File Streaming</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>file_to_event.xPath</code></p></td>
<td style="text-align: left;"><p><code>String</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>provide a xPath filter to stream xml objects from a xml file. Use with fileFormat value 4 i.e. XML File Streaming</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>directory_wildcard.wildcard_type</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0, 1, 2</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>Set this property to apply regular expression on files. 0 → disabled 1 → whitelist files or directory 2 → blacklist files or directory</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>directory_wildcard.config_path</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>provide absolute file path location containing regular expression. The file should be in .cfg format</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>directory_replication.start_time</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>-1, 0, any number &gt; 0</code></p></td>
<td style="text-align: left;"><p><code>-1</code></p></td>
<td style="text-align: left;"><p>Set this property to filter files in directory based on modified time.</p>
<p>-1 will consider the timestamp in checkpoint if available or will replicate all files again.</p>
<p>0 will override the timestamp in checkpoint and will consider files modified since midnight.</p>
<p>Any value(epoch time) other than 0 or -1 will consider files modified after the epoch time</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>solace_out.lvq</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Provide the LVQ name configured on Solace broker. Connector will connect to this queue on start to fetch checkpoint information.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>solace_out.destination</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>LVQ topic - Connector will publish checkpoint information and the base topic will be same as output destination topic configured in connection details section. LVQ topic is built as follows</p>
<p>1. In case of Static or Directory replication connector will append /checkpoint to base topic(&lt;output-destination-topic&gt;) and will publish data. The LVQ created on Solace broker should have this subscription &lt;output-destination-topic&gt;/checkpoint</p>
<p>2. In case of Dynamic file connector will not append /checkpoint to base topic(&lt;output-destination-topic&gt;) and will publish data. The LVQ created on Solace broker should have this subscription &lt;output-destination-topic&gt;.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
</tbody>
</table>

### File Sink Configuration Options

These configuration options are all prefixed by `file.sink.`:

<table>
<colgroup>
<col style="width: 28%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 28%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>general.adapter_id</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Unique ID for the connector instance</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.auto_create_directory</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0 or 1</code></p></td>
<td style="text-align: left;"><p><code>1</code></p></td>
<td style="text-align: left;"><p>If the directory doesn’t exist connector will create the directory. Set to zero to disable it</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.dest_file_name_type</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>1,2,3,4,5,6</code></p></td>
<td style="text-align: left;"><p><code>3</code></p></td>
<td style="text-align: left;"><p>Set this property to define the sink file location. Sink file location can be determined as follows.</p>
<p>Set to 1 Sink file location - output destination + fileID(this is generated by the source when reading file)</p>
<p>Set to 2 Sink file location - Source file absolute path</p>
<p>Set to 3 Sink file location - Destination file absolute path configured at Source Connector</p>
<p>Set to 4 Sink file location - output destination + Source file absolute path</p>
<p>Set to 5 Sink file location - output destination + Destination file absolute path set at the source</p>
<p>Set to 6 Sink file location - output destination + Destination file relative path found at the source</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.storeBackupStateRemotely</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true,false</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>When set to true, Sink connector will create the backup state file on the remote Channel (GCS, SFTP, FTP, FTPs) configured</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.state_backup_path</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Absolute file location to store Sink Connector’s checkpoint information. The file should end in .cfg format(Ex:&lt;path&gt;/sink_connector_state_backup.cfg. The file will be created by connector if it doesn’t exist.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.clear_state_on_eod</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0, 1</code></p></td>
<td style="text-align: left;"><p><code>1</code></p></td>
<td style="text-align: left;"><p>Connector preserves the last successful file state in backup file, so that it resumes from checkpoint on next restart. If this property is set to 1 connector will clear the file state in backup file when End of Day configured time is reached. Set to 0 if file state in backup file need not be cleared</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.eod_time_sec</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>-1,0, any number &gt; 0</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>Connector will exit once configured EOD is elapsed. For example if connector need to be exited every day at 5 A.M EOD should be configured to 104400. The formula to calculate EOD is (24 Hours + (number of hours(24 hour format) when connector should exit))*3600. In our example (24+5)*3600 = 104400. Set this to 0 is connector need to exit at midnight every day and -1 to disable this check</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>general.alwaysVerifyData</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true,false</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>When set to true, Sink connector will additionally validate if the last multipart was written successfully as an additional data integrity check</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>general.alwaysMatchCompleteEvent</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true,false</code></p></td>
<td style="text-align: left;"><p><code>true</code></p></td>
<td style="text-align: left;"><p>When set to false, the sink connector will not match the complete event stats with the Source Connector as an additional data integrity check</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>file_owner_permissions.copy_source_file_mode_permissions</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0, 1</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>When configuring this section, connector need to be run as sudo user. 0 → Do not copy file permissions received from source file, 1 → copy file permissions received from source file</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>file_owner_permissions.copy_source_file_owner</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0, 1, 2</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>When configuring this section, connector need to be run as sudo user. 0 → Do not copy file owner &amp; group received from source file, 1 → copy file owner &amp; group received from source file, 2 → ignore source file owner and group and set overide_username and override_group as username and group</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>file_owner_permissions.override_username</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>When set the owner name from source is ignored and configured user will be set as owner</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>file_owner_permissions.override_group</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>When set the group name from source is ignored and configured group will be set as group</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
</tbody>
</table>

## Remote Protocol Configuration

By default, Micro-Integration will automatically read and write files on the local file system unless the supported remote protocols are enabled in the configuration.

The following remote protocols are supported

`1. Google Cloud Storage`

`2. SSH File Transfer Protocol or Secure File Transfer Protocol (SFTP)`

`3. File Transfer Protocol (FTP/FTPs)`

### Google Cloud Storage

Google Cloud Storage is a service for storing objects in Google Cloud.

An object is an immutable piece of data consisting of a file of any format. You store objects in containers called buckets.

All buckets are associated with a project, and you can group your projects under an organization.

These configuration options are all prefixed by `file.source.` or `file.sink.`

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>gcs.enabled</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>false, true</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>Set this value to false to disable and true to enable Google Cloud Storage as source location.</p>
<p>Default false, the file will be searched for on the local source machine and if set to true, the files/blobs will be pulled from a remote location on the Google Cloud Storage</p>
<p>If enabled, advanced.maxEventsPerFile property will automatically set to 1.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>gcs.projectId</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>ProjectId value from Google Cloud Storage.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>gcs.credentialsFilePath</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Credentials file path in JSON format to access Google Cloud Storage.</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>gcs.enableBulkComposeStrategy</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true,false</code></p></td>
<td style="text-align: left;"><p><code>true</code></p></td>
<td style="text-align: left;"><p>When set to true, the sink connector will request to compose multipart blobs in bulk at the end of receiving the last Multipart.</p>
<p>If set to false, sequential compose strategy will be applied to compose all multiparts to create the final file</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>gcs.retrySettings.maxAttempts</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>Integer Value</code></p></td>
<td style="text-align: left;"><p><code>10</code></p></td>
<td style="text-align: left;"><p>Maximum Retry Attempts in case of connection failure</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>gcs.retrySettings.retryDelayMultiplier</code></p></td>
<td style="text-align: left;"><p><code>double</code></p></td>
<td style="text-align: left;"><p><code>Double Value</code></p></td>
<td style="text-align: left;"><p><code>3.0</code></p></td>
<td style="text-align: left;"><p>Retry Delay Multiplier in case of connection failure</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>gcs.retrySettings.maxDurationMinutes</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>Integer Value</code></p></td>
<td style="text-align: left;"><p><code>5</code></p></td>
<td style="text-align: left;"><p>Maximum Duration of retries in minutes in case of connection failure</p></td>
</tr>
</tbody>
</table>

### Secure File Transfer Protocol (SFTP)

Secure File Transfer Protocol (SFTP) is a network protocol for securely accessing, transferring and managing large files and sensitive data.

SFTP uses SSH to transfer files and requires that the client be authenticated by the server.

Commands and data are encrypted to prevent passwords and other sensitive information from being exposed to the network in plain text.

The authenticaiton methods supported are `Password` OR using `Private Key`

These configuration options are all prefixed by `file.source.` or `file.sink.`

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>sftp_settings.enabled</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>false, true</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>Set this value to false to disable and true to enable SFTP source location.</p>
<p>Default false, the file will be searched for on the local source machine and if set to true, the files will be pulled from a remote location on the sftp server</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>sftp_settings.ip</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>SFTP Server IP</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>sftp_settings.port</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>22</code></p></td>
<td style="text-align: left;"><p>SFTP server port number</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>sftp_settings.user</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>SFTP user username</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>sftp_settings.password</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>SFTP user password</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>sftp_settings.strictHostKeyChecking</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>yes, no</code></p></td>
<td style="text-align: left;"><p><code>yes</code></p></td>
<td style="text-align: left;"><p>Enable or disable the Strict Host Key checking while creating a connection to the sftp server.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>sftp_settings.privateKeyPath</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Path to the privateKey File to authenticate using private key instead of password</p></td>
</tr>
</tbody>
</table>

### File Transfer Protocol (FTP/FTPs)

The File Transfer Protocol (FTP) is a standard communication protocol used for the transfer of computer files from a server to a client on a computer network.

FTP is built on a client–server model architecture using separate control and data connections between the client and the server.

FTP users may authenticate themselves with a plain-text sign-in protocol, normally in the form of a username and password, but can connect anonymously if the server is configured to allow it.

For secure transmission that protects the username and password, and encrypts the content, FTP is often secured with SSL/TLS (FTPS)

Both `FTP` or `FTP secure` are supported

These configuration options are all prefixed by `file.source.` or `file.sink.`

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>ftp_settings.enabled</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>false, true</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>Set this value to false to disable and true to enable FTP/FTPs source location.</p>
<p>Default false, the file will be searched for on the local source machine and if set to true, the files will be pulled from a remote location on the ftp server</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>ftp_settings.ip</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>FTP Server IP</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>ftp_settings.port</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>21</code></p></td>
<td style="text-align: left;"><p>FTP server port number</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>ftp_settings.user</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>FTP user username</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>ftp_settings.password</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>FTP user password</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>ftp_settings.secured</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true,false</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>For connecting over FTPs - TLS/secured</p></td>
</tr>
</tbody>
</table>

## File Mesh Manager

All the file replications can be monitored on File Mesh Manager (Command Center) dashboard. The connector publishes the health, replication state to File Mesh Manager which analyses and represents the data in graphical representation.

File Mesh Manager is a separate package that need to be deployed as separate instance, which is built on ReactJS, NodeJS and uses postgres or oracle as databases.

File Mesh Manager can connect to the queue on configured Solace Instance to read and process file micro-integration state events.

Once processed the information is represented on Dashboard.

### Configuration Options

These configuration options are all prefixed by `file.source.` or `file.sink.`

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Config Option</th>
<th style="text-align: left;">Type</th>
<th style="text-align: left;">Valid Values</th>
<th style="text-align: left;">Default Value</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>command_center.enabled</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0,1</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>Set this value to 0 to disable sending events to command center and 1 to enable sending events to command center</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>command_center.useOutputDestinationSolaceCredentials</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true, false</code></p></td>
<td style="text-align: left;"><p><code>true</code></p></td>
<td style="text-align: left;"><p>true → uses solace java credentials configured, false → If different Solace instance details need to be used, configure using below properties</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>command_center.solace_ip</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Full Solace Host address(tcp://host-name:55555)</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>command_center.solace_vpn</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Solace VPN name</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>command_center.solace_user</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Solace client username</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>command_center.solace_password</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Solace client password</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>command_center.solace_base_publish_topic</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Base publish topic for command center event. Connector will append adapter_id in first row and event state(start, complete, error, warning) to the topic when publishing data.Ex(&lt;command_center.solace_base_publish_topic&gt;/&lt;adapter_id&gt;/&lt;event_state&gt;). This following topic subscription need to be added to command center queue</p>
<p>1. &lt;command_center.solace_base_publish_topic&gt;/*/start</p>
<p>2. &lt;command_center.solace_base_publish_topic&gt;/*/complete</p>
<p>3. &lt;command_center.solace_base_publish_topic&gt;/*/error</p>
<p>4. &lt;command_center.solace_base_publish_topic&gt;/*/warning</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>command_center.solace_messaging_mode</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>DIRECT, PERSISTENT, NON-PERSISTENT</code></p></td>
<td style="text-align: left;"><p><code>PERSISTENT</code></p></td>
<td style="text-align: left;"><p>Set the message mode (DIRECT, PERSISTENT, NON-PERSISTENT)</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>command_center.heartbeat_enabled</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>0, 1</code></p></td>
<td style="text-align: left;"><p><code>0</code></p></td>
<td style="text-align: left;"><p>Set this to 1 to enable sending heartbeats to command center(Command Center need to be enabled as well). 0 will disable sending heart beat events</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>command_center.heartbeat_interval</code></p></td>
<td style="text-align: left;"><p><code>int</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>30</code></p></td>
<td style="text-align: left;"><p>Integer value representing number of seconds to wait before sending heartbeat. This will work only if heartbeat is enabled.</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>command_center.solace_base_publish_topic_heartbeat</code></p></td>
<td style="text-align: left;"><p><code>string</code></p></td>
<td style="text-align: left;"><p><code>any</code></p></td>
<td style="text-align: left;"><p><code>empty</code></p></td>
<td style="text-align: left;"><p>Base publish topic for heartbeat event. Connector will append adapter_id in first row and event state(heartbeat) to the topic when publishing data.Ex(&lt;command_center.solace_base_publish_topic_heartbeat&gt;/&lt;adapter_id&gt;/&lt;event_state&gt;). This following topic subscription need to be added to heartbeat queue</p>
<p>1. &lt;command_center.solace_base_publish_topic_heartbeat&gt;/*/heartbeat</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p><code>command_center.events.fileStart</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true, false</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>true → send file start events for every file to Command Center</p>
<p>false → No file start event</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p><code>command_center.events.fileComplete</code></p></td>
<td style="text-align: left;"><p><code>boolean</code></p></td>
<td style="text-align: left;"><p><code>true, false</code></p></td>
<td style="text-align: left;"><p><code>false</code></p></td>
<td style="text-align: left;"><p>true → send file complete events for every file to Command Center</p>
<p>false → No file complete event</p></td>
</tr>
</tbody>
</table>

## License

This project is licensed under the Apache License, Version 2.0. - See the `LICENSE` file for details.

### Support

Support is offered best effort via our [Solace Developer Community].

Premium support options are available, please [Contact Solace].

  [Preface]: #preface
  [Getting Started]: #getting-started
  [Prerequisites]: #prerequisites
  [Quick Start common steps]: #quick-start-common-steps
  [Quick Start: Running the connector via command line]: #quick-start-running-the-connector-via-command-line
  [Quick Start: Running the connector via `start.sh` script]: #quick-start-running-the-connector-via-start-sh-script
  [Quick Start: Running the connector as a Container]: #quick-start-running-the-connector-as-a-container
  [Enabling Workflows]: #enabling-workflows
  [Configuring Connection Details]: #configuring-connection-details
  [Solace PubSub+ Connection Details]: #solace-pubsub-connection-details
  [Connecting to Multiple Systems]: #connecting-to-multiple-systems
  [User-configured Header Transforms]: #user-configured-header-transforms
  [User-configured Payload Transforms]: #user-configured-payload-transforms
  [Registered Functions]: #registered-functions
  [Message Headers]: #message-headers
  [Solace Headers]: #solace-headers
  [Reserved Message Headers]: #reserved-message-headers
  [Management and Monitoring Connector]: #management-and-monitoring-connector
  [Monitoring Connector’s States]: #monitoring-connectors-states
  [Health]: #health
  [Workflow Health]: #workflow-health
  [Solace Binder Health]: #solace-binder-health
  [Leader Election]: #leader-election
  [Leader Election Modes: Standalone / Active-Active]: #leader-election-modes-standalone-active-active
  [Leader Election Mode: Active-Standby]: #leader-election-mode-active-standby
  [Leader Election Management Endpoint]: #leader-election-management-endpoint
  [Workflow Management]: #workflow-management
  [Workflow Management Endpoint]: #workflow-management-endpoint
  [Workflow States]: #workflow-states
  [Metrics]: #metrics
  [Connector Meters]: #connector-meters
  [Add a Monitoring System]: #add-a-monitoring-system
  [Security]: #security
  [Securing Endpoints]: #securing-endpoints
  [Consuming Object Messages]: #consuming-object-messages
  [Adding External Libraries]: #adding-external-libraries
  [Configuration]: #configuration
  [Providing Configuration]: #providing-configuration
  [Spring Configuration Options]: #spring-configuration-options
  [Connector Configuration Options]: #connector-configuration-options
  [Workflow Configuration Options]: #workflow-configuration-options
  [File Specific Configuration]: #file-specific-configuration
  [File Source Configuration Options]: #file-source-configuration-options
  [File Sink Configuration Options]: #file-sink-configuration-options
  [Remote Protocol Configuration]: #remote-protocol-configuration
  [Google Cloud Storage]: #google-cloud-storage
  [Secure File Transfer Protocol (SFTP)]: #secure-file-transfer-protocol-sftp
  [File Transfer Protocol (FTP/FTPs)]: #file-transfer-protocol-ftpftps
  [File Mesh Manager]: #file-mesh-manager
  [Configuration Options]: #configuration-options
  [License]: #license
  [Support]: #support
  [Solace PubSub+ Event Broker]: https://solace.com/products/event-broker/
  [1]: #configuring-connection-details
  [2]: #configuration
  [here]: #note-users-list
  [the connector’s container documentation]: https://hub.docker.com/r/solace/solace-pubsub-connector-file
  [Spring Cloud Stream Reference Guide]: https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html
  [Spring Cloud Stream Binder for Solace PubSub+]: https://github.com/SolaceProducts/solace-spring-cloud/tree/master/solace-spring-cloud-starters/solace-spring-cloud-stream-starter
  [Spring Boot Auto-Configuration for the Solace Java API]: https://github.com/SolaceProducts/solace-spring-boot/tree/master/solace-spring-boot-starters/solace-java-spring-boot-starter
  [3]: https://github.com/SolaceProducts/solace-spring-boot/tree/master/solace-spring-boot-starters/solace-java-spring-boot-starter#updating-your-application-properties
  [`reject-msg-to-sender-on-discard` with the `including-when-shutdown`]: https://docs.solace.com/Admin-Ref/CLI-Reference/VMR_CLI_Commands.html#Root_enable_configure_message-spool_queue_reject-msg-to-sender-on-discard
  [multiple binder syntax]: https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html#multiple-systems
  [Spring Expression Language (SpEL)]: https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#expressions
  [4]: https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#expressions-ref-functions
  [5]: #user-configured-header-transforms
  [6]: https://github.com/SolaceDev/solace-spring-cloud/tree/master/solace-spring-cloud-starters/solace-spring-cloud-stream-starter#solace-message-headers
  [Spring Integration: Message Headers]: https://docs.spring.io/spring-integration/reference/html/message.html#message-headers
  [Spring Boot Actuator]: https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#actuator
  [Spring Boot Actuator health endpoint]: https://docs.spring.io/spring-cloud-stream/docs/3.2.2/reference/html/spring-cloud-stream.html#_health_indicator
  [Spring Boot documentation]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.endpoints.health
  [Workflow Health Resolution Diagram]: data:image/png;base64,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
  [Solace binder]: https://github.com/SolaceDev/solace-spring-cloud/tree/master/solace-spring-cloud-starters/solace-spring-cloud-stream-starter#solace-binder-health-indicator
  [Spring Actuator]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.endpoints
  [`bindings` management endpoint]: https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html#_actuator
  [Spring Boot Metrics]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics
  [Datadog]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics.export.datadog
  [Dynatrace]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics.export.dynatrace
  [Influx]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics.export.influx
  [JMX]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics.export.jmx
  [OpenTelemetry (OTLP)]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics.export.otlp
  [StatsD]: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics.export.statsd
  [the connector’s classpath]: #adding-external-libraries
  [7]: #management-and-monitoring-connector
  [Spring Boot - Configure SSL]: https://docs.spring.io/spring-boot/docs/current/reference/html/howto.html#howto.webserver.configure-ssl
  [TLS Setup in Spring]: https://www.baeldung.com/spring-tls-setup
  [Spring Boot - PropertiesLauncher Features]: https://docs.spring.io/spring-boot/docs/current/reference/html/executable-jar.html#appendix.executable-jar.property-launcher
  [Spring Boot: Externalized Configuration]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config
  [Spring documentation]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.typesafe-configuration-properties.relaxed-binding.environment-variables
  [Spring Boot: Profile-Specific Files]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files.profile-specific
  [Spring Boot’s default locations]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files
  [8]: #quick-start-running-the-connector-via-command-line
  [Spring Boot Actuator Info Endpoint]: https://docs.spring.io/spring-boot/docs/current/actuator-api/htmlsingle/#info
  [build]: https://docs.spring.io/spring-boot/docs/current/actuator-api/htmlsingle/#info.retrieving.response-structure.build
  [Spring Cloud Stream]: https://docs.spring.io/spring-cloud-stream/docs/current/reference/html/spring-cloud-stream.html#_configuration_options
  [9]: https://github.com/SolaceProducts/solace-spring-cloud/tree/master/solace-spring-cloud-starters/solace-spring-cloud-stream-starter#configuration-options
  [Spring Logging]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.logging
  [Solace Developer Community]: https://solace.community/
  [Contact Solace]: https://solace.com/contact-us
