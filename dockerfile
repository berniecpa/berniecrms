FROM php:8.1-apache-bullseye

# Enable Apache rewrite
RUN a2enmod rewrite \
 && { \
      echo '<Directory /var/www/html>'; \
      echo '    AllowOverride All'; \
      echo '</Directory>'; \
    } > /etc/apache2/conf-available/allow-override.conf \
 && a2enconf allow-override

# Install system dependencies (Bullseye has libc-client2007e-dev)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libc-client2007e-dev \
    libkrb5-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    unzip zip \
 && rm -rf /var/lib/apt/lists/*

# Configure gd & imap
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Build PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    mysqli pdo pdo_mysql curl mbstring iconv imap gd zip

# Enable them
RUN docker-php-ext-enable mysqli pdo_mysql curl mbstring iconv imap gd zip

# Force allow_url_fopen=On
RUN echo "allow_url_fopen=On" > /usr/local/etc/php/conf.d/zz-allow-url-fopen.ini

EXPOSE 80