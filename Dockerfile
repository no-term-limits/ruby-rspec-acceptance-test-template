##### START POTENTIAL BASE IMAGE
# This portion could be split into own image and used only when needed by the next section

# Stolen unapologetically from https://github.com/seapy/dockerfiles/blob/master/ruby/Dockerfile
# check package sizes with: dpkg-query -W --showformat='${Installed-Size;10}\t${Package}\n' | sort -k1,1n
# base image size is currently around 1.11GB, Ubuntu 20.04 is around 115MB, /opt/rubies/ruby-3.0.2 is around 260MB, and google-chrome-beta is around 200MB
FROM ubuntu:20.04 as compile_ruby_and_gems

ARG RUBY_VERSION_FOR_INSTALL=3.0.2

MAINTAINER burnettk

# Add Ruby binaries to $PATH
ENV PATH /opt/rubies/ruby-$RUBY_VERSION_FOR_INSTALL/bin:$PATH
ENV RUBY_INSTALL_VERSION_NOT_RUBY_VERSION=0.8.1

WORKDIR /app

# Need this for tzdata
ENV DEBIAN_FRONTEND noninteractive

# package explanations:
# software-properties-common for add-apt-repository
# nodejs - not sure why. needed for execjs at runtime, but installed below
# MySQL(for mysql, mysql2 gem, running mysql client)
# wget, curl, vim since these containers are actually used
# build-essential git git-core: ruby dependencies including eventmachine gem.
# zlib1g-dev to libxslt1-dev: ruby dependencies
# install ruby as part of the same command, since if we delete the apt metadata first, ruby-install won't run
RUN apt-get update &&\
  apt-get install -qq -y wget curl libcurl4 libcurl4-gnutls-dev \
  build-essential git git-core \
  zlib1g-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libtinfo-dev \
  nodejs libmysqlclient-dev mysql-client tzdata &&\
  apt-get install -qq -y libcurl4-openssl-dev &&\
  cd /tmp &&\
  wget -O ruby-install-$RUBY_INSTALL_VERSION_NOT_RUBY_VERSION.tar.gz https://github.com/postmodern/ruby-install/archive/v$RUBY_INSTALL_VERSION_NOT_RUBY_VERSION.tar.gz &&\
  tar -xzvf ruby-install-$RUBY_INSTALL_VERSION_NOT_RUBY_VERSION.tar.gz &&\
  cd ruby-install-$RUBY_INSTALL_VERSION_NOT_RUBY_VERSION/ &&\
  make install &&\
  ruby-install ruby $RUBY_VERSION_FOR_INSTALL &&\
  echo 'installed ruby' &&\
  echo "install: --no-document --no-ri\nupdate: --no-document --no-ri" > ~/.gemrc &&\
  echo 'about to install bundler' &&\
  gem install bundler &&\
  cd /app &&\
  rm -rf /var/lib/apt/lists/* &&\
  rm -rf /tmp/ruby* &&\
  rm -rf /usr/local/src &&\
  rm -rf /opt/rubies/ruby-$RUBY_VERSION_FOR_INSTALL/share/ri/2.3.0 &&\
  apt-get clean

ENV DEBIAN_FRONTEND=

################################
FROM ubuntu:20.04 as final_image

ARG RUBY_VERSION_FOR_INSTALL=3.0.2
ARG PHANTOMJS_VERSION=phantomjs-2.1.1-linux-x86_64

# Add Ruby binaries to $PATH
ENV PATH /opt/rubies/ruby-$RUBY_VERSION_FOR_INSTALL/bin:$PATH

ENV TERM xterm

COPY --from=compile_ruby_and_gems /opt/rubies/ruby-$RUBY_VERSION_FOR_INSTALL /opt/rubies/ruby-$RUBY_VERSION_FOR_INSTALL

# Install Ruby App
WORKDIR /app

# Need this for tzdata
ENV DEBIAN_FRONTEND noninteractive

RUN  apt-get update && apt-get install -qq -y gnupg \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 00A6F0A3C300EE8C \
  && apt-get install -y apt-transport-https ca-certificates curl libcurl4 libcurl4-gnutls-dev --no-install-recommends \
  && apt-get install -qq -y libcurl4-openssl-dev \
  && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update && apt-get install -y \
  cron iputils-ping libyaml-dev unzip net-tools \
  libmysqlclient-dev sqlite3 tzdata ca-certificates vim build-essential nodejs git git-core \
  google-chrome-stable \
  firefox firefox-geckodriver \
  fontconfig \
  fonts-ipafont-gothic \
  fonts-wqy-zenhei \
  fonts-thai-tlwg \
  fonts-kacst \
  fonts-symbola \
  fonts-noto \
  fonts-freefont-ttf \
  --no-install-recommends \
  && wget https://chromedriver.storage.googleapis.com/$(curl http://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip \
  && unzip chromedriver_linux64.zip \
  && mv chromedriver /usr/bin/chromedriver \
  && chmod +x /usr/bin/chromedriver \
  && curl -L https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOMJS_VERSION.tar.bz2 -o $PHANTOMJS_VERSION.tar.bz2 \
  && tar xjf $PHANTOMJS_VERSION.tar.bz2 \
  && cp $PHANTOMJS_VERSION/bin/phantomjs /usr/bin \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -qq clean

ENV DEBIAN_FRONTEND=

RUN groupadd --gid 2020 app
RUN useradd -g app --uid 2020 --create-home --shell /bin/false app
RUN chown app:app -R /opt/rubies
RUN chsh --shell /bin/bash app
USER app

# ONBUILD USER root
# ONBUILD RUN chown app:app -R /app
# ONBUILD USER app

# probably delete these lines in favor of ONBUILDs
USER root
RUN chown app:app -R /app
USER app

##### END OF POTENTIAL BASE IMAGE


##### START PORTION TO BUILD EVERYTIME
# This will probably need to build everytime and could use the previous section as its base image

# FROM ghcr.io/ruby-rspec-acceptance-tests/selenium-headless-chrome-ruby:jenkins-docker-selenium-headless-chrome-ruby-main-3

WORKDIR /app

ENV LANG=C.UTF-8
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN mkdir -p /app/vendor/gems
ADD vendor/gems/status-api-acceptance-test-helper /app/vendor/gems/status-api-acceptance-test-helper
RUN bundle install

ADD . /app
