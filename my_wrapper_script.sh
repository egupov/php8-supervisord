#!/bin/bash

# Start the first process
php-fpm &

# Start the second process
supervisord -n -c /etc/supervisor/supervisord.conf &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?