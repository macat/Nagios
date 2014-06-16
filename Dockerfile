FROM damon/base

# Add the postgresql repo as a source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update -qq

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq --force-yes \
    autoconf imagemagick libcurl4-openssl-dev libevent-dev libglib2.0-dev \
    libjpeg-dev libjpeg62 libpng12-0 libpng12-dev libmagickcore-dev \
    libmagickwand-dev libpq-dev libssl-dev libssl0.9.8 libxml2-dev \
    libxslt-dev nodejs openssh-server postgresql-client-9.3 python-pip socat \
    vim wget zlib1g-dev gawk libreadline6-dev libyaml-dev \
    supervisor

# Install bundler
RUN gem install --no-ri --no-rdoc bundler

# Add the SSH dir
RUN mkdir -p /var/run/sshd

# Install Grunt
RUN npm install -g grunt-cli

# Cleanup
RUN apt-get autoremove -y && apt-get clean -y

# Set home for root
ENV HOME /root
RUN mkdir -p "${HOME}/.ssh"

# Setup the root user
ENV RUBYOPT -Ku
RUN echo "gem: --no-ri --no-rdoc" > "${HOME}/.gemrc"
RUN ln -s /state/source "${HOME}/www"

# Add our sshd config
ADD sshd_config /etc/ssh/sshd_config

# Add our supervisor config
ADD supervisord.conf /etc/supervisor/supervisord.conf

# Add our setup script
ADD setup /scripts/setup

# Add the database config for rails
ADD database.yml /database.yml

# Default environment variables
ENV APP_PATH /state/source

# Expose the rails and ssh ports
EXPOSE 3000
EXPOSE 22

# Use our run script as the entrypoint
CMD /scripts/setup
