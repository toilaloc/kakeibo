FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  mariadb-client \
  default-libmysqlclient-dev \
  libyaml-dev \
  git \
  curl \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV GEM_HOME=/usr/local/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

# Install bundler
RUN gem install bundler

# Copy Gemfile & lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy app source
COPY . .

RUN mkdir -p log tmp/pids tmp/sockets tmp/cache

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
