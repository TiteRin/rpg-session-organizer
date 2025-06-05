#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Start the Rails server in the background
echo "Starting Rails server..."
bundle exec rails server -b 0.0.0.0 -p ${PORT:-8080} --log-to-stdout &
RAILS_PID=$!

# Wait for the server to be ready
echo "Waiting for server to be ready..."
until curl -s http://localhost:${PORT:-8080}/api/health > /dev/null; do
  echo "Server not ready yet... waiting"
  sleep 2
done

echo "Server is ready!"
wait $RAILS_PID 