FROM php:8.1-apache-bullseye

# Install everything in one layer
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev \
    libzip-dev libonig-dev libc-client-dev libkrb5-dev \
    zip unzip git curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql mysqli gd zip imap \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory and copy files
WORKDIR /var/www/html
COPY . .

# Fix permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

EXPOSE 80