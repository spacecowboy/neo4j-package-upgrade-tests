#!/usr/bin/env bash
set -eu

source helpers.sh

# This is the supported upgrade path:
# https://neo4j.com/docs/operations-manual/current/upgrade/#supported-upgrade-paths

usage() {
  >&2 echo "Usage: ${0} --from=<VERSION> --to=<VERSION> --distribution=<community|enterprise>"
}

missing() {
  >&2 echo "Missing required argument: $1"
  usage
}

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h|--help)
      usage
      exit 0
      ;;
    -f=*|--from=*)
      FROM="${key#*=}"
      ;;
    -t=*|--t=*)
      TO="${key#*=}"
      ;;
    -d=*|--distribution=*)
      DIST="${key#*=}"
      ;;
    *)
      # unknown option
      echo "Unknown option ${key}"
      usage
      exit 1
      ;;
  esac
  shift # past argument or value
done

if [ -z "${FROM+set}" ]; then
  missing "from"
  exit 1
fi

if [ -z "${TO+set}" ]; then
  missing "to"
  exit 1
fi

if [ -z "${DIST+set}" ]; then
  missing "distribution"
  exit 1
fi

echo "FROM=${FROM}"
echo "TO=${TO}"
echo "DIST=${DIST}"

# Add repo
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | tee /etc/apt/sources.list.d/neo4jstable.list
echo 'deb https://debian.neo4j.org/repo testing/' | tee /etc/apt/sources.list.d/neo4jtesting.list
apt update

# Install from
if [[ ${DIST} == "enterprise" ]]; then
  FROMPKG="neo4j-enterprise"
else
  FROMPKG="neo4j"
fi

apt install -y "${FROMPKG}=${FROM}"

# Stop neo4j
systemctl stop neo4j

# Disable auth
disable_auth

# Start neo4j
systemctl start neo4j

# Wait for neo4j to be up
neo4j_wait

# Create node
neo4j_createnode

# Read it back
neo4j_readnode

# Allow format migration
allow_format_migration

# Upgrade neo4j
