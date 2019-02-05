#!/bin/sh

# Start service
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n  > /dev/null
