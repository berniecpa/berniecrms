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
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    # IMAP dependencies
    libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# Install libc-client for IMAP (special handling required)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libc-client2007e-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure GD with all image support
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

# Configure IMAP with SSL support
RUN docker-php-ext-configure imap \
    --with-kerberos \
    --with-imap-ssl

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
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