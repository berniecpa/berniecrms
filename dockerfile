FROM php:8.1-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libc-client-dev \
    libkrb5-dev \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap mysqli pdo pdo_mysql curl openssl mbstring iconv gd zip intl

# Enable Apache mod_headers (recommended for .htaccess/CORS)
RUN a2enmod headers

# Enable allow_url_fopen
RUN echo "allow_url_fopen = On" >> /usr/local/etc/php/conf.d/docker-php-custom.ini

# Set working directory (optional, change as needed)
WORKDIR /var/www/html

# Expose HTTP port
EXPOSE 80

