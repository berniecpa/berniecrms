FROM php:8.1-apache

# Install system dependencies required for PHP extensions
RUN apt-get update && apt-get install -y \
    # For IMAP extension
    libc-client-dev \
    libkrb5-dev \
    # For GD extension
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    # For Zip extension
    libzip-dev \
    # For various extensions
    libssl-dev \
    libcurl4-openssl-dev \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    curl \
    mbstring \
    iconv \
    imap \
    gd \
    zip

# Enable Apache modules
RUN a2enmod rewrite ssl

# Configure PHP settings
RUN echo "allow_url_fopen = On" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/custom.ini

# Set working directory
WORKDIR /var/www/html

# Copy your application files (uncomment and modify as needed)
# COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80
