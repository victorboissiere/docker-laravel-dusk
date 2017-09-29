FROM php:7.0

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install packages
RUN apt-get update -yqq && apt-get install -y git wget curl libcurl4-gnutls-dev libicu-dev libmcrypt-dev libvpx-dev libjpeg-dev libpng-dev  \
      libxpm-dev zlib1g-dev libfreetype6-dev libxml2-dev libexpat1-dev libbz2-dev \
      libgmp3-dev libldap2-dev unixodbc-dev libpq-dev libsqlite3-dev libaspell-dev \
      libsnmp-dev libpcre3-dev libtidy-dev -yqq bzip2 libfontconfig xvfb chromium libmagickwand-dev apt-transport-https ca-certificates

# Increase PHP memory allocation
RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 200M;" >> /usr/local/etc/php/conf.d/uploads.ini

# Add chrome repo and install google-chrome-stable
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update
RUN apt-get install -y google-chrome-stable

# Install php environment
RUN docker-php-ext-install mbstring mcrypt pdo_mysql curl json intl gd xml zip bz2 opcache bcmath

# Install imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# check installed modules
RUN php -m

# Install NVM
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
    && apt-get update && apt-get install yarn

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
RUN google-chrome-stable --version
RUN composer --version
RUN php -m
