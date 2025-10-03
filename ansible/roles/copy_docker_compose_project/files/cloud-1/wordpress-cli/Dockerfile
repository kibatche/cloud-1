FROM wordpress:cli-2.12.0-php8.2

WORKDIR /config
COPY ./config/config_wordpress.sh /config/config_wordpress.sh
CMD [ "bash", "/config/config_wordpress.sh" ]