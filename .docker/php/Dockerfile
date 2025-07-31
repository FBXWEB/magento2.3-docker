FROM php:7.3-fpm

# Variáveis de ambiente

ENV USER=fbxweb
ENV GROUP=fbxweb


# Instala dependências
RUN apt-get update && apt-get install -y \
    git zip unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libonig-dev libxslt-dev libicu-dev g++ \
    libcurl4-openssl-dev pkg-config libssl-dev cron nano vim \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_mysql zip gd intl xsl soap opcache bcmath sockets \
    && pecl channel-update pecl.php.net \
    && pecl install redis-5.3.7 \
    && docker-php-ext-enable redis

# Instala Composer 1 (Magento 2.3.x não suporta Composer 2)
RUN curl -sS https://getcomposer.org/installer | php -- --1 \
    && mv composer.phar /usr/bin/composer

# Configurações PHP CLI
RUN echo "memory_limit = 4G" > /usr/local/etc/php/conf.d/memory-limit.ini
RUN echo "max_execution_time = 1800" > /usr/local/etc/php/conf.d/exec-time.ini

# Define o diretório de trabalho
WORKDIR /var/www/html

# Create User and Group
RUN groupadd -g 1000 ${GROUP} && useradd -u 1000 -ms /bin/bash -g ${GROUP} ${USER}

# Grant Permissions
RUN chown -R ${USER} /var/www/html

# Select User
USER ${USER}

# Copy permission to selected user
COPY --chown=${USER}:${GROUP} . .

# Expõe a porta padrão do php-fpm
EXPOSE 9000

# Inicia o PHP-FPM
CMD ["php-fpm"]
