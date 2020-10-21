FROM php:7.1.30-apache

ENV APACHE_DOCUMENT_ROOT /var/www/html

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y curl \
    sudo \
    wget \
    git \
    unzip \
    zip \
    libxml2-dev \
    libpng-dev \
    libyaml-dev \
    cron

RUN docker-php-ext-install pdo_mysql && docker-php-ext-enable pdo_mysql && \
    docker-php-ext-install bcmath && docker-php-ext-enable bcmath && \
    docker-php-ext-install gd && docker-php-ext-enable gd && \
    docker-php-ext-install soap && docker-php-ext-enable soap && \
    pecl install yaml && docker-php-ext-enable yaml && \
    pecl install redis-4.3.0 && docker-php-ext-enable redis && \
    pecl install mongodb && docker-php-ext-enable mongodb

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

#WORKDIR /var/www/html
#RUN composer install

COPY crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab
RUN touch /var/log/cron.log

COPY index.php ${APACHE_DOCUMENT_ROOT}/index.php

RUN apt-get autoremove -y && apt-get clean && apt-get autoclean

CMD cron && tail -f /var/log/cron.log