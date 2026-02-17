# pubsubplus-connector-file
Solace
Corporation https://solace.com

*Revision: 2.3.0*
<br/>*Revision Date: 2023-07-05*

## Table of Contents

-   [Preface]
-   [Getting Started]
    -   [Prerequisites]
    -   [Usage]
    -   [Connecting to Services on the Host]
    -   [Configuring a Healthcheck]
-   [Providing Configuration]
-   [Ports]
-   [Volumes]
    -   [Volume: Spring Configuration Files]
    -   [Volume: Libraries]
    -   [Volume: Classpath Files]
    -   [Volume: Output Files]
-   [Configuring the JVM]
    -   [Support]
-   [License]

## Preface

Solace PubSub+ File Connector replicates files from Source to Sink

## Getting Started

[Release Notes]

### Prerequisites

-   [Docker] or [Podman]

-   [PubSub+ Event Broker]

-   File

### Usage

### Connecting to Services on the Host

If services (for example a PubSub+ event broker) are exposed on the localhost, they can be referenced using the container platform’s special DNS name with `SOLACE_JAVA_HOST`, which resolves to an internal IP address that’s used by the host.

For example in Docker, use the following command:

    docker run -d --name my-connector \
      -v `pwd`/libs/:/app/external/libs/:ro \
      -v `pwd`/config/:/app/external/spring/config/:ro \
      --env SOLACE_JAVA_HOST=host.docker.internal:55555 \
      solace/solace-pubsub-connector-file:2.3.0

For example in Docker, use the following command:

    podman run -d --name my-connector \
      -v `pwd`/libs/:/app/external/libs/:ro \
      -v `pwd`/config/:/app/external/spring/config/:ro \
      --env SOLACE_JAVA_HOST=host.containers.internal:55555 \
      solace/solace-pubsub-connector-file:2.3.0

### Configuring a Healthcheck

You can configure the health to perform the following tasks:

-   Create a regular read-only user called `healthcheck` with a password using `SOLACE_CONNECTOR_SECURITY_USERS_0_NAME` and `SOLACE_CONNECTOR_SECURITY_USERS_0_PASSWORD`.

-   Use the `healthcheck` user as the user to poll the management health endpoint in the container’s `healthcheck` command and fails it if the connector is unhealthy.

Here’s a basic example command of how to configure the health check for container:

For example in Docker, use the following command:

    docker run -d --name my-connector \
      -v `pwd`/libs/:/app/external/libs/:ro \
      -v `pwd`/application.yml:/app/external/spring/config/application.yml:ro \
      --env SOLACE_CONNECTOR_SECURITY_USERS_0_NAME=healthcheck \
      --env SOLACE_CONNECTOR_SECURITY_USERS_0_PASSWORD=healthcheck \
      --healthcheck-command="curl -X GET -u healthcheck:healthcheck --fail localhost:8090/actuator/health" \
      solace/solace-pubsub-connector-file:2.3.0

For example in Podman, use the following command:

    podman run -d --name my-connector \
      -v `pwd`/libs/:/app/external/libs/:ro \
      -v `pwd`/application.yml:/app/external/spring/config/application.yml:ro \
      --env SOLACE_CONNECTOR_SECURITY_USERS_0_NAME=healthcheck \
      --env SOLACE_CONNECTOR_SECURITY_USERS_0_PASSWORD=healthcheck \
      --healthcheck-command="curl -X GET -u healthcheck:healthcheck --fail localhost:8090/actuator/health" \
      solace/solace-pubsub-connector-file:2.3.0

## Providing Configuration

You can provide Spring configuration properties to this container using one of the following ways:

1.  Use [environment variables].

2.  Use [volumes containing Spring configuration files] (as well as other volumes).

## Ports

The following ports are required for the container:

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Port</th>
<th style="text-align: left;">Usage</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><code>8090</code></p></td>
<td style="text-align: left;"><p>The connector’s management endpoint.</p></td>
</tr>
</tbody>
</table>

## Volumes

These are the supported directories for which volumes and bind mounts can be created:

<table>
<colgroup>
<col style="width: 20%" />
<col style="width: 40%" />
<col style="width: 20%" />
<col style="width: 20%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Contents</th>
<th style="text-align: left;">Container Path</th>
<th style="text-align: left;">Optional</th>
<th style="text-align: left;">Recommended Permission</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>Spring configuration files</p></td>
<td style="text-align: left;"><p><code>/app/external/spring/config/</code></p></td>
<td style="text-align: left;"><p>Required unless all properties are defined using environment variables</p></td>
<td style="text-align: left;"><p>Read-Only</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>Libraries</p></td>
<td style="text-align: left;"><p><code>/app/external/libs/</code></p></td>
<td style="text-align: left;"><p>Required</p></td>
<td style="text-align: left;"><p>Read-Only</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>Classpath files</p></td>
<td style="text-align: left;"><p><code>/app/external/classpath/</code></p></td>
<td style="text-align: left;"><p>Optional</p></td>
<td style="text-align: left;"><p>Read-Only</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>Output files</p></td>
<td style="text-align: left;"><p><code>/app/external/output/</code></p></td>
<td style="text-align: left;"><p>Optional</p></td>
<td style="text-align: left;"><p>Read/Write</p></td>
</tr>
</tbody>
</table>

### Volume: Spring Configuration Files

The Spring configuration files volume is used to add Spring configuration files (such as `application.yml`, etc.), add a read-only volume, or bind mount to `/app/external/spring/config/`.

This directory follows the same semantics as [Spring’s default `config/` directory]. That fact means that this connector automatically finds and loads Spring configuration files from the following locations when the connector starts:

1.  The root of `/app/external/spring/config/`.

2.  Immediate child directories of `/app/external/spring/config/`.

> **TIP**
> 
> If you want configuration files for multiple, different connectors within the same `config` directory for use in different environments (such as development, production, etc.), we recommend that you use [Spring Boot Profiles] instead of child directories. For example:
> 
> -   Set up your configuration like this:
> 
>     -   `/app/external/spring/config/application-prod.yml`
> 
>     -   `/app/external/spring/config/application-dev.yml`
> 
> -   Do not do this:
> 
>     -   `/app/external/spring/config/prod/application.yml`
> 
>     -   `/app/external/spring/config/dev/application.yml`
> 
> Child directories are intended to be used for merging configuration from multiple sources of configuration properties. For more information and an example of when you might want to use multiple child directories to compose your application's configuration, see the [Spring Boot documentation].
> 
>   [Spring Boot Profiles]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files.profile-specific
>   [Spring Boot documentation]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files.wildcard-locations

### Volume: Libraries

The Libraries volume adds additional libraries, adds a read-only volume, or binds a mount to `/app/external/libs/`.

This directory is provided as the location for the Java library dependencies (external JAR files) that are
required only when using certain features of the Connector (such as Prometheus libraries when using the metrics export to Prometheus feature in your Connector configuration).

See the documentation provided in the `libs` directory of the connector in the ZIP file for more information.

### Volume: Classpath Files

The Classpath Files volume adds a location for arbitrary files (not JAR libraries nor Spring Boot configuration files), adds a read-only volume, or binds a mount to `/app/external/classpath/`.

> **NOTE**
> 
> This directory must not contain JAR files for libraries or Spring Boot configuration files, otherwise there is a risk of libraries not getting picked up during the deployment of the connector and overwriting the connector's internal configuration.

### Volume: Output Files

The Output Files volume is for some features that support writing output files, such as logging to a file. To capture these, add a read/write volume or bind the mount to `/app/external/output/` directory.

> **IMPORTANT**
> 
> When using features that generates files, you must configure the features so that the files are generated to the `/app/external/output/` directory. Generating files to any other directory is not supported.

## Configuring the JVM

You can set the `JDK_JAVA_OPTIONS` environment variable on the container to configure the Java Virtual Machine (JVM).

See [the JDK documentation] for more information.

> **TIP**
> 
> This container is provided as an example and has been tested using:
> 
> -   Two active processors (specified using `-XX:ActiveProcessorCount=2`).
> 
> -   A maximum heap memory of 2 GB (specified using `-Xmx2048m`).

### Support

Support is offered best effort via our [Solace Developer Community].

Premium support options are available, please [Contact Solace].

## License

This project is licensed under the Apache License, Version 2.0. - See the `LICENSE` file under the container’s `/licenses` for details.

  [Preface]: #preface
  [Getting Started]: #getting-started
  [Prerequisites]: #prerequisites
  [Usage]: #usage
  [Connecting to Services on the Host]: #connecting-to-services-on-the-host
  [Configuring a Healthcheck]: #configuring-a-healthcheck
  [Providing Configuration]: #providing-configuration
  [Ports]: #ports
  [Volumes]: #volumes
  [Volume: Spring Configuration Files]: #_volume_spring_configuration_files
  [Volume: Libraries]: #volume-libraries
  [Volume: Classpath Files]: #volume-classpath-files
  [Volume: Output Files]: #volume-output-files
  [Configuring the JVM]: #configuring-the-jvm
  [Support]: #support
  [License]: #license
  [Release Notes]: https://solace.com/connectors/pubsubplus-connector-file
  [Docker]: https://www.docker.com/
  [Podman]: https://podman.io/
  [PubSub+ Event Broker]: https://solace.com/products/event-broker/
  [environment variables]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.typesafe-configuration-properties.relaxed-binding.environment-variables
  [volumes containing Spring configuration files]: #_volume_spring_configuration_files
  [Spring’s default `config/` directory]: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.files
  [the JDK documentation]: https://docs.oracle.com/en/java/javase/17/docs/specs/man/java.html#using-the-jdk_java_options-launcher-environment-variable
  [Solace Developer Community]: https://solace.community/
  [Contact Solace]: https://solace.com/contact-us
