FROM php:8.5-rc-fpm-alpine

RUN apk update && apk add curl
# COPY ./conf/www.conf /etc/php/7.3/fpm/pool.d/www.conf
COPY ./init/entrypoint.sh /opt/entrypoint.sh
RUN mkdir -p /run/php
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar && mv wp-cli.phar /opt/wp && chmod +x /opt/entrypoint.sh
# RUN rm -r /etc/php/7.3/fpm/pool.d/www.conf

ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD [ "php-fpm" ]