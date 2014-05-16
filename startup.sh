#!/bin/bash

ENV_CONF=/etc/php5/fpm/pool.d/env.conf

# Update php5-fpm with access to Docker environment variables
echo '[www]' > $ENV_CONF
for var in $(env | grep MYSQL_ | awk -F= '{print $1}')
do
    echo "env[${var}] = ${!var}" >> $ENV_CONF
done

service php5-fpm start
nginx -g "daemon off;"