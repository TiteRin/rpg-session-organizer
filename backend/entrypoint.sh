#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Start the Rails server
exec bundle exec rails server -b 0.0.0.0 -p ${PORT:-8080} --log-to-stdout 