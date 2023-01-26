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
COPY ./etc/php8/supervisord.conf /etc/supervisor/supervisord.conf

# Expose port 9000 and start php-fpm server
EXPOSE 9000
COPY ./etc/php8-alpine/my_wrapper_script.sh /usr/bin/my_wrapper_script.sh
CMD /usr/bin/my_wrapper_script.sh