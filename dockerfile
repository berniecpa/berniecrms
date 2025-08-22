# Use official PHP image with Apache
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    # Dependencies for GD extension
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    # Dependencies for IMAP extension
    libc-client-dev \
    libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    && docker-php-ext-configure imap \
    --with-kerberos \
    --with-imap-ssl \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    mysqli \
    zip \
    gd \
    imap

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install Composer globally
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files to container
COPY . .

# Fix file permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80