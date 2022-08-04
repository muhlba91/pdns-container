#!/bin/bash
set -e

SQLITE3_CMD="sqlite3 ${PDNS_CONF_GSQLITE3_DATABASE}"

# initialiaze domains
echo Initializing Domains

INPUT=/data/domains.csv
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 0; }

while read name; do
  cat >>/tmp/domains.sql <<EOF
INSERT INTO domains (
  name,
  type
)

VALUES (
  '$name',
  'NATIVE'
)

ON CONFLICT DO NOTHING;
EOF
done < $INPUT
IFS=$OLDIFS

cat /tmp/domains.sql | $SQLITE3_CMD

# initialize TSIG keys
echo Initializing TSIG Keys

INPUT=/data/tsig.csv
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 0; }

while read domain name secret; do
  cat >>/tmp/tsig.sql <<EOF
INSERT INTO tsigkeys (
  name,
  algorithm,
  secret
)

VALUES (
  '$name',
  'hmac-sha256',
  '$secret'
)

ON CONFLICT DO NOTHING;

INSERT INTO domainmetadata (
  domain_id,
  kind,
  content
)

VALUES (
  (SELECT id FROM domains WHERE name = '$domain'),
  'TSIG-ALLOW-AXFR',
  '$name'
)

ON CONFLICT DO NOTHING;
EOF
done < $INPUT
IFS=$OLDIFS

cat /tmp/tsig.sql | $SQLITE3_CMD

# initialize records
echo Initializing Records

INPUT=/data/records.csv
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 0; }

while read domain name type content; do
  cat >>/tmp/records.sql <<EOF
DELETE FROM records WHERE domain_id = (SELECT id FROM domains WHERE name = '$domain') AND name = '$name' AND type = '$type';

INSERT INTO records (
  domain_id,
  name,
  type,
  content,
  ttl,
  prio,
  disabled,
  auth
)

VALUES (
  (SELECT id FROM domains WHERE name = '$domain'),
  '$name',
  '$type',
  '$content',
  300,
  0,
  false,
  true
)

ON CONFLICT DO NOTHING;
EOF
done < $INPUT
IFS=$OLDIFS

cat /tmp/records.sql | $SQLITE3_CMD
