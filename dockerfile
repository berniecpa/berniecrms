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
    # Dependencies needed for IMAP
    libkrb5-dev \
    libssl-dev \
    libpam0g-dev \
    && rm -rf /var/lib/apt/lists/*

# Manually install IMAP from source
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    && cd /tmp \
    && wget https://github.com/uw-imap/imap/archive/refs/heads/master.tar.gz \
    && tar -xzf master.tar.gz \
    && cd imap-master \
    && make lnp SSLTYPE=unix EXTRACFLAGS=-fPIC \
    && mkdir -p /usr/local/imap-2007f/{lib,include} \
    && cp c-client/*.h /usr/local/imap-2007f/include/ \
    && cp c-client/*.c /usr/local/imap-2007f/lib/ \
    && cp c-client/c-client.a /usr/local/imap-2007f/lib/libc-client.a \
    && cd /tmp \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    && docker-php-ext-configure imap \
    --with-kerberos \
    --with-imap-ssl \
    --with-imap=/usr/local/imap-2007f \
    && docker-php-ext-install -j$(nproc) \
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