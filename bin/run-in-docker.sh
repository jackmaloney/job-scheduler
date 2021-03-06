#!/usr/bin/env sh

print_help() {
  echo "Script to run docker containers for Job Scheduler API service

  Usage:

  ./run-in-docker.sh [OPTIONS]

  Options:
    --clean, -c                   Clean and install current state of source code
    --install, -i                 Install current state of source code
    --param PARAM=, -p PARAM=     Parse script parameter
    --help, -h                    Print this help block

  Available parameters:
    DB_PASSWORD   Defaults to 'dev'
    S2S_URL       Defaults to 'localhost'
    S2S_SECRET    Defaults to 'secret'
  "
}

# script execution flags
GRADLE_CLEAN=false
GRADLE_INSTALL=false

# environment variables
DB_PASSWORD=dev
S2S_URL=localhost
S2S_SECRET=secret

execute_script() {
  cd $(dirname "$0")/..

  if [ ${GRADLE_CLEAN} = true ]
  then
    echo "Clearing previous build.."
    ./gradlew clean
  fi

  if [ ${GRADLE_INSTALL} = true ]
  then
    echo "Installing distribution.."
    ./gradlew installDist
  fi

  echo "Assigning environment variables.."

  export JOB_SCHEDULER_DB_PASSWORD=${DB_PASSWORD}
  export S2S_URL=${S2S_URL}
  export S2S_SECRET=${S2S_SECRET}

  echo "Bringing up docker containers.."

  docker-compose up
}

while true ; do
  case "$1" in
    -h|--help) print_help ; shift ; break ;;
    -c|--clean) GRADLE_CLEAN=true ; GRADLE_INSTALL=true ; shift ;;
    -i|--install) GRADLE_INSTALL=true ; shift ;;
    -p|--param)
      case "$2" in
        DB_PASSWORD=*) DB_PASSWORD="${2#*=}" ; shift 2 ;;
        S2S_URL=*) S2S_URL="${2#*=}" ; shift 2 ;;
        S2S_SECRET=*) S2S_SECRET="${2#*=}" ; shift 2 ;;
        *) shift 2 ;;
      esac ;;
    *) execute_script ; break ;;
  esac
done
