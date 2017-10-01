FROM ubuntu:16.04

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install packages
RUN apt-get update -yqq && apt-get install -y git wget curl chromium-browser php

# Laravel Dusk
RUN google-chrome &

# Install php environment
RUN apt-get install -y php-mbstring php-mcrypt php-mysql php-curl php-zip php-xml

# check installed modules
RUN php -m

# Install NVM
RUN apt-get install -y apt-transport-https
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.11.3
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install Composer Package manager
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php \
    php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer

# confirm installed versions
RUN node -v
RUN npm -v
RUN php -v
RUN yarn -v
RUN chromium-browser --version
RUN composer --version
RUN php -m
