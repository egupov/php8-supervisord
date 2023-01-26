FROM php:8.1.5-fpm-alpine

WORKDIR /var/www/

# Essentials
RUN echo "UTC" > /etc/timezone
RUN apk add --no-cache zip unzip curl sqlite nginx supervisor

# Installing bash
RUN apk add bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Installing supervisor
RUN apk update && apk add --no-cache supervisor
RUN mkdir -p "/etc/supervisor/logs"
COPY ./etc/php8-alpine/supervisord.conf /etc/supervisor/supervisord.conf

# Installing pgsql
RUN apk --no-cache update \
    && apk add --no-cache autoconf g++ make \
    postgresql-dev \
    \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    \
    && docker-php-ext-install pdo_pgsql

# Installing mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Installing Rabbit-client
RUN apk add --no-cache rabbitmq-c rabbitmq-c-dev && \
    mkdir -p /usr/src/php/ext/amqp && \
    curl -fsSL https://pecl.php.net/get/amqp | tar xvz -C "/usr/src/php/ext/amqp" --strip 1 && \
    docker-php-ext-install amqp

# Expose port 9000 and start php-fpm server
EXPOSE 9000
RUN chmod -R 777 /var/www/storage
COPY ./etc/php8-alpine/my_wrapper_script.sh /usr/bin/my_wrapper_script.sh
CMD /usr/bin/my_wrapper_script.sh