#!/bin/sh

while [[ ! -f "/var/log/pdns/current" ]]; do
    sleep 1
done

exec tail -f /var/log/pdns/current