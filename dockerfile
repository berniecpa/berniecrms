FROM php:8.4-apache

# Install everything in one RUN command for smaller image
RUN apt-get update && apt-get install -y \
    gcc g++ make autoconf libc-dev pkg-config \
    libkrb5-dev libc-client-dev libssl-dev \
    libpng-dev libjpeg-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev \
    libzip-dev zip unzip git curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql mysqli gd zip \
    && pecl install imap \
    && docker-php-ext-enable imap \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory and copy files
WORKDIR /var/www/html
COPY . .

# Fix permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

EXPOSE 80