#!/bin/sh

echo Checking for dhcp availability

until dhclient eth1
do
  logger "waiting for dhcp..."
  sleep 3
done
