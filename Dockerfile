FROM ubuntu:14.04

MAINTAINER Luis Elizondo "lelizondo@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Update system
RUN apt-get update && apt-get dist-upgrade -y

# Basic packages
RUN apt-get -y install php5-fpm php5-mysql php-apc php5-imagick php5-imap php5-mcrypt php5-curl php5-cli php5-gd php5-pgsql php5-sqlite php5-common php-pear curl php5-json php5-redis php5-memcache
RUN apt-get -y install nginx

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/
RUN mv /usr/bin/composer.phar /usr/bin/composer

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configuration
ADD ./config/realip.conf /etc/nginx/conf.d
ADD ./config/default /etc/nginx/sites-available/default

# Startup script
ADD ./startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

RUN sed -i 's/memory_limit = .*/memory_limit = 196M/' /etc/php5/fpm/php.ini

EXPOSE 80

CMD ["/opt/startup.sh"]