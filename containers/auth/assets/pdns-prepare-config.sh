#!/bin/bash
set -e

export GSQLITE3_DATABASE=${PDNS_CONF_GSQLITE3_DATABASE:-"/var/lib/pdns/pdns.sqlite"}

SCHEMA_VERSION_TABLE="_schema_version"

GSQLITE3_CMD="sqlite3 ${GSQLITE3_DATABASE}"

# init database if necessary
if [[ -z "$(printf '.tables' | ${GSQLITE3_CMD})" ]]; then
  echo "Initializing Database"
  cat /usr/share/doc/pdns/schema.sqlite3.sql | ${GSQLITE3_CMD}
  INITIAL_DB_VERSION=${PDNS_GSQLITE3_VERSION}
fi

# init version database if necessary
if [[ -z "$(echo ".table ${SCHEMA_VERSION_TABLE}" | ${GSQLITE3_CMD})" ]]; then
  [ -z "${INITIAL_DB_VERSION}" ] && >&2 echo "Error: INITIAL_DB_VERSION is required the first time" && exit 1
  echo "CREATE TABLE ${SCHEMA_VERSION_TABLE} (id SERIAL PRIMARY KEY, version VARCHAR(255) DEFAULT NULL)" | ${GSQLITE3_CMD}
  echo "INSERT INTO ${SCHEMA_VERSION_TABLE} (version) VALUES ('${INITIAL_DB_VERSION}');" | ${GSQLITE3_CMD}
  echo "Initialized schema version to ${INITIAL_DB_VERSION}"
fi

# do the database upgrade
while true; do
  current="$(echo "SELECT version FROM ${SCHEMA_VERSION_TABLE} ORDER BY id DESC LIMIT 1;" | ${GSQLITE3_CMD})"
  if [ "$current" != "${PDNS_GSQLITE3_VERSION}" ]; then
    filename=/usr/share/doc/pdns/${current}_to_*_schema.sqlite3.sql
    echo "Applying Update $(basename ${filename})"
    ${GSQLITE3_CMD} < ${filename}
    current=$(basename ${filename} | sed -n 's/^[0-9.]\+_to_\([0-9.]\+\)_.*$/\1/p')
    echo "INSERT INTO ${SCHEMA_VERSION_TABLE} (version) VALUES ('${current}');" | ${GSQLITE3_CMD}
  else
    break
  fi
done

# convert all environment variables prefixed with PDNS_CONF_ into pdns config directives
PDNS_LOAD_MODULES="$(echo ${PDNS_LOAD_MODULES} | sed 's/^,//')"
printenv | grep ^PDNS_CONF_ | cut -f3- -d_ | while read var; do
  val="${var#*=}"
  var="${var%%=*}"
  var="$(echo ${var} | sed -e 's/_/-/g' | tr '[:upper:]' '[:lower:]')"
  (grep -qE "^[# ]*${var}=.*" /etc/pdns/pdns.conf && sed -r -i "s#^[# ]*${var}=.*#${var}=${val}#g" /etc/pdns/pdns.conf) || echo "${var}=${val}" >> /etc/pdns/pdns.conf
done

# environment hygiene
for var in $(printenv | cut -f1 -d= | grep -v -e HOME -e USER -e PATH ); do
  unset ${var};
done
export TZ=UTC LANG=C LC_ALL=C
