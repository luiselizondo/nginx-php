FROM ubuntu:14.04

MAINTAINER Luis Elizondo "lelizondo@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Update system
RUN apt-get update && apt-get dist-upgrade -y

# Basic packages
RUN apt-get -y install php5-fpm php5-mysql php-apc php5-imagick php5-imap php5-mcrypt php5-curl php5-cli php5-gd php5-pgsql php5-sqlite php5-common php-pear curl php5-json php5-redis php5-memcache
RUN apt-get -y install nginx
RUN apt-get -y install git curl supervisor

RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN php5enmod mcrypt

RUN /usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php
RUN /bin/mv composer.phar /usr/local/bin/composer
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configuration

ADD ./config/nginx.conf /etc/nginx/nginx.conf
ADD ./config/default /etc/nginx/sites-available/default
ADD ./config/realip.conf /etc/nginx/conf.d/realip.conf
ADD ./config/supervisor.conf /etc/supervisor/conf.d/supervisord-nginx.conf
ADD ./config/php.ini /etc/php5/fpm/php.ini

## Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/memory_limit = .*/memory_limit = 196M/' /etc/php5/fpm/php.ini
RUN sed -i 's/cgi.fix_pathinfo = .*/cgi.fix_pathinfo = 0/' /etc/php5/fpm/php.ini

# Startup script
# This startup script wll configure nginx
ADD ./startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

RUN mkdir /var/www

RUN mkdir /var/www/test
ADD ./config/index.php /var/www/test/index.php

RUN usermod -u 1000 www-data
RUN chown -R www-data:www-data /var/www

EXPOSE 80

WORKDIR /var/www

CMD ["/usr/bin/supervisord", "-n"]