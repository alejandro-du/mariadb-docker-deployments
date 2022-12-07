#!/usr/bin/with-contenv bash

echo "server_id = $RANDOM" >> /config/custom.cnf
/init
