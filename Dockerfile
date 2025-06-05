FROM ruby:3.3.0

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock
COPY backend/Gemfile backend/Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the rest of the backend application
COPY backend/ .

# Add a script to be executed every time the container starts
COPY backend/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-8080}", "--log-to-stdout"] 