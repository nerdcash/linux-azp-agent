#!/bin/bash
 
dockerd > /var/log/dockerd.log 2>&1 &
./start.sh
 