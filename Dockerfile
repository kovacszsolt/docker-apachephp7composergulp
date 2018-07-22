FROM debian:jessie
RUN apt-get -y update
RUN apt-get install -y git wget apt-transport-https lsb-release ca-certificates memcached
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get -y update
RUN apt-get install -y curl apache2 php7.1 php7.1-mysql php7.1-json php7.1-curl php7.1-gd php7.1-xml php7.1-mbstring mysql-client
ENV COMPOSER_ALLOW_SUPERUSER=1
# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

# install apache2

# turn off some apache modules
RUN rm /etc/apache2/mods-enabled/status.conf
RUN rm /etc/apache2/mods-enabled/status.load
RUN rm /etc/apache2/mods-enabled/autoindex.conf
RUN rm /etc/apache2/mods-enabled/autoindex.load
RUN rm /etc/apache2/mods-enabled/alias.conf
RUN rm /etc/apache2/mods-enabled/alias.load
# turn on some apache modules
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
COPY files/apache2.conf /etc/apache2/apache2.conf
COPY files/000-default.conf /etc/apache2/sites-available/000-default.conf

# create apache enviroment file

COPY files/envvars /etc/apache2/envvars
COPY files/php.ini /etc/php5/apache2/php.ini

RUN mkdir /apache/
RUN mkdir /apache/conf/
RUN mkdir /apache/log/
RUN mkdir /apache/tmp/
RUN mkdir /apache/source/
RUN mkdir /apache/source/default/
RUN mkdir /apache/source/default/public/
RUN chmod -r /apache/source/*

COPY files/index.html.default /apache/source/default/public/index.html

#################
# run apache2 service
ENTRYPOINT service apache2 restart && /bin/bash
