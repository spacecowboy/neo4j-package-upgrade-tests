disable_auth() {
  echo "dbms.security.auth_enabled=false" >> /etc/neo4j/neo4j.conf
}

allow_format_migration() {
  echo "dbms.allow_format_migration=true" >> /etc/neo4j/neo4j.conf
}

neo4j_wait() {
  local l_time="30"
  local l_ip="localhost"
  end="$((SECONDS+${l_time}))"

  while true; do
    [[ "200" = "$(curl --silent --write-out '%{http_code}' --output /dev/null http://${l_ip}:7474)" ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done
}

neo4j_createnode() {
  local l_ip="localhost" end="$((SECONDS+30))"

  [[ "201" = "$(curl --silent --write-out '%{http_code}' --request POST --output /dev/null http://${l_ip}:7474/db/data/node)" ]] || exit 1
}

neo4j_readnode() {
  local l_time="5"
  local l_ip="localhost" end="$((SECONDS+${l_time}))"

  while true; do
    [[ "200" = "$(curl --silent --write-out '%{http_code}' --output /dev/null http://${l_ip}:7474/db/data/node/0)" ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done
}
