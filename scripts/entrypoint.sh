#!/bin/sh

# start health check server in background
python -m src.health_check &

# execute the main command
exec "$@"
