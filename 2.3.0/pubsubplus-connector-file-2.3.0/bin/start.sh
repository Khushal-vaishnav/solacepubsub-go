#!/bin/bash

ACTIVE_PROFILE=
LIBS_FOLDER=./libs
CONFIG_FOLDER=./
JAR_FILE=pubsubplus-connector-file-2.3.0.jar
JVM_OPTS=
RUN_STRING="java"
BACKGROUND=false
OVERWRITTEN_PARAMETERS=

CM=false
CM_HOST="127.0.0.1"
CM_PORT="9500"

C_HOST="127.0.0.1"
C_PORT="8090"
MGMT_PORT="9009"

TLS="http"

SHOW_CMD=false

CMD=()
ERRS=()

function message_pref {
  echo 'pubsubplus-connector-file'
}

function usage {
  message_pref
  echo "Usage: start.sh [-n NAME] [-l FOLDER] [-p PROFILE] [-c FOLDER] [-H HOST] [-P PORT] "
  echo "[-j FILE] [-cm] [-cmh HOST] [-cmp PORT] [-mp PORT] [-o OPTIONS] [-tls] [-b] [-s] [-h]"
  echo
  echo "To start connector use following parameters:"
  echo "-n   | --name        Name of the Connector instance, set up in [spring.application.name]. This name impacts"
  echo "                     on grouping connectors only."
  echo "-l   | --libs        Directory containing required and optional dependency jars, such as Micrometer metrics "
  echo "                     export dependencies (if configured). If not specified, it will use the current [./libs/] "
  echo "                     folder"
  echo "-p   | --profile     Profile to be used for connector configuration. The configuration file named"
  echo "                     [application-<profile>.yml] will be used. Default value is empty, no profile is used,"
  echo "                     which means Connector will be looking for configuration file, called [application.yml]"
  echo "-c   | --config      Path to the folder containing the configuration files to be applied during connector"
  echo "                     startup for chosen profile. By default it is set to the current folder and automatically "
  echo "                     looking in the nested and sibling [config] folders (if any), as well as in the current"
  echo "                     and parent folders"
  echo "-H   | --host        Provides host where Connector will be running on. Default value is set to [127.0.0.1]"
  echo "-P   | --port        Provides port where Connector will be running on. Default value is set to [8090]"
  echo "-mp  | --mgmt_port   Provides management port for back calls of current Connector from Connector Manager."
  echo "                     Default value is set to [9009]. Ignored if [-cm] argument is missing"
  echo "-j   | --jar         Path to specified JAR file to start Connector. If not specified, the default jar file is"
  echo "                     used, from the current folder"
  echo "-cm  | --manager     Allow to enable cloud configuration for Connector by using Connector Manager configuration"
  echo "                     storage"
  echo "-cmh | --cm_host     Specifies the host where Connector Manager is running. Default value is set to [127.0.0.1]"
  echo "                     Ignored if [-cm] argument is missing"
  echo "-cmp | --cm_port     Specifies the port where Connector Manager is running. Default value is set to [9500]. "
  echo "                     Ignored if [-cm] argument is missing"
  echo "-o   | --options     Specifies JVM options used on Connector start. Example: ['-Xms64M -Xmx1G']. It is "
  echo "                     important to use single/double quotes specifying parameters"
  echo "-b   | --background  Runs the Connector Manager in the background. No logs will be displayed and Connector"
  echo "                     continues running in detached mode"
  echo "-tls                 Use HTTPS instead of HTTP"
  echo "-s   | --show        This option prints the start CLI command in raw and exit"
  echo "-h   | --help        Print this help page and exit"
}

function print_errors {
  message_pref
  echo "Connector startup failed:"
  echo
  for ERR in "${ERRS[@]}"; do
    echo "$ERR"
  done
  echo
  exit 1
}

function check_file {
  if [ ! -f "$1" ]; then
    ERRS+=("The following file doesn't exist on your filesystem:       '$1'")
  fi
}

function check_folder {
  if [ ! -d "$1" ]; then
    ERRS+=("The following folder doesn't exist on your filesystem:     '$1'")
  fi
}

function set_lib_folder {
  LIBS_FOLDER="$1"
  check_folder "$LIBS_FOLDER"
}

function set_active_profile {
  ACTIVE_PROFILE="$1"
}

function set_config_folder {
  CONFIG_FOLDER="$1"

  #adding trailing slash
  case "$1" in
  *)
    CONFIG_FOLDER="$CONFIG_FOLDER/"
    ;;
  esac

  check_folder "$CONFIG_FOLDER"
}

function set_jar_file {
  JAR_FILE="$1"
  check_file "$JAR_FILE"
}

function set_jvm_opts {
  JVM_OPTS="$1"
}

function set_background_run {
  BACKGROUND=true
}

function search_for_config_file {
  if [ -z "$ACTIVE_PROFILE" ]; then
    CONFIG_FILE="application."
  else
    CONFIG_FILE="application-$ACTIVE_PROFILE."
  fi

  #current folder
  if ls $CONFIG_FOLDER$CONFIG_FILE* 1> /dev/null 2>&1; then
    CONFIG_FOLDER=$CONFIG_FOLDER
    return
  fi

  #parent folder
  if ls $CONFIG_FOLDER"../"$CONFIG_FILE* 1> /dev/null 2>&1; then
    CONFIG_FOLDER=$CONFIG_FOLDER"../"
    return
  fi

  #current folder/config
  if ls $CONFIG_FOLDER"./config/"$CONFIG_FILE* 1> /dev/null 2>&1; then
    CONFIG_FOLDER=$CONFIG_FOLDER"config/"
    return
  fi

  #parent folder/config
  if ls $CONFIG_FOLDER"../config/"$CONFIG_FILE* 1> /dev/null 2>&1; then
    CONFIG_FOLDER=$CONFIG_FOLDER"../config/"
    return
  fi

  ERRS+=("Couldn't find configuration file "$CONFIG_FILE" for profile: $ACTIVE_PROFILE in "$CONFIG_FOLDER)
}

while [ "$1" != "" ]; do
  case $1 in
  -l | --libs)
    shift
    set_lib_folder "$1"
    ;;
  -n | --name)
    shift
    OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --spring.application.name=$1"
    ;;
  -p | --profile)
    shift
    set_active_profile "$1"
    ;;
  -c | --config)
    shift
    set_config_folder "$1"
    ;;
  -H | --host)
    shift
    C_HOST=$1
    ;;
  -P | --port)
    shift
    C_PORT=$1
    ;;
  -mp | --mgmt_port)
    shift
    MGMT_PORT=$1
    ;;
  -j | --jar)
    shift
    set_jar_file "$1"
    ;;
  -cm | --manager)
    CM=true
    ;;
  -cmp | --cm_port)
    shift
    CM_PORT=$1
    ;;
  -cmh | --cm_host)
    shift
    CM_HOST=$1
    ;;
  -o | --options)
    shift
    set_jvm_opts "$1"
    ;;
  -b | --background)
    set_background_run
    ;;
  -s | --show)
    SHOW_CMD=true
    ;;
  -tls)
    TLS="https"
    ;;
  -h | --help)
    usage
    exit
    ;;
  esac
  shift
done

OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --server.host=$C_HOST --server.port=$C_PORT"

if [ "$CM" = true ]; then
  # set connector Manager data
  OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --spring.config.import='optional:configserver:$TLS://$CM_HOST:$CM_PORT/config/'"
  OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --spring.boot.admin.client.instance.service-url='$TLS://$C_HOST:$MGMT_PORT/'"
  OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --spring.boot.admin.client.instance.management-url='$TLS://$C_HOST:$MGMT_PORT/actuator'"
  OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --spring.boot.admin.client.instance.health-url='$TLS://$C_HOST:$MGMT_PORT/actuator/health'"
  OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --management.server.port=$MGMT_PORT"
  OVERWRITTEN_PARAMETERS=$OVERWRITTEN_PARAMETERS" --spring.boot.admin.client.url='$TLS://$CM_HOST:$CM_PORT/'"
fi

search_for_config_file "$CONFIG_FOLDER"
if [ -z $JAR_FILE ]; then
    ERRS+=("You need to specify JAR file to start up the connector")
fi

if ((${#ERRS[@]} != 0)); then
  # shellcheck disable=SC2128
  print_errors "$ERRS"
fi

BASE_RUN_STRING="-Dloader.path=$LIBS_FOLDER -Dspring.profiles.active=$ACTIVE_PROFILE -jar $JAR_FILE --spring.config.additional-location=$CONFIG_FOLDER $OVERWRITTEN_PARAMETERS"

if [[ $SHOW_CMD == true ]]; then
    echo "---"
    echo "$RUN_STRING" "$JVM_OPTS" "$BASE_RUN_STRING"
    echo "---"
    exit 0
fi

message_pref
echo 'Starting the pubsubplus-connector-file...'

if [ "$BACKGROUND" = true ]; then
  CMD=("nohup" "$RUN_STRING" "$JVM_OPTS" "$BASE_RUN_STRING" ">/dev/null 2>&1 &")
  eval "${CMD[@]}"
  echo "The pubsubplus-connector-file started with PID: "$!
  exit
else
  CMD=("$RUN_STRING" "$JVM_OPTS" "$BASE_RUN_STRING")
  eval "${CMD[@]}"
fi
