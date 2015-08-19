#!/bin/sh --

# Update and then load the IP/CIDR tables to pf(4)
# This script is for cron(8). 

/opt/sbin/update-pf-tables.sh
/opt/sbin/load-pf-tables.sh


