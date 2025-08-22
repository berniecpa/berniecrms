# PHP + Apache (Debian-based) with required extensions
FROM php:8.1-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Make sure .htaccess rules can work (AllowOverride All)
RUN set -eux; \
  { \
    echo '<Directory /var/www/html>'; \
    echo '    AllowOverride All'; \
    echo '</Directory>'; \
  } > /etc/apache2/conf-available/allow-override.conf && \
  a2enconf allow-override

# System deps for building PHP extensions
# Notes:
# - IMAP needs libc-client (package name on Debian is libc-client2007e-dev) and Kerberos headers
# - GD needs libjpeg/libpng/freetype
# - ZIP needs libzip
# - cURL needs libcurl
RUN set -eux; \
  apt-get update; \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libc-client2007e-dev \
    libkrb5-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    unzip \
    zip \
  ; \
  rm -rf /var/lib/apt/lists/*

# Configure extensions that need options (gd, imap)
RUN set -eux; \
  docker-php-ext-configure gd --with-freetype --with-jpeg; \
  docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Build & enable PHP extensions
# - mysqli
# - pdo & pdo_mysql
# - curl
# - openssl (built-in since PHP 8, no separate install step required)
# - mbstring
# - iconv
# - imap
# - gd
# - zip
RUN set -eux; \
  docker-php-ext-install -j"$(nproc)" \
    mysqli \
    pdo \
    pdo_mysql \
    curl \
    mbstring \
    iconv \
    imap \
    gd \
    zip \
  ; \
  docker-php-ext-enable \
    mysqli \
    pdo_mysql \
    curl \
    mbstring \
    iconv \
    imap \
    gd \
    zip

# PHP config: ensure allow_url_fopen is enabled
RUN echo "allow_url_fopen=On" > /usr/local/etc/php/conf.d/zz-allow-url-fopen.ini

# (Optional) Set a sane timezone (uncomment & change if needed)
# RUN echo "date.timezone=UTC" > /usr/local/etc/php/conf.d/timezone.ini

# Expose Apache port (already exposed by base image, but explicit for clarity)
EXPOSE 80

# Copy your app into the image (optional; otherwise mount via volumes)
# COPY . /var/www/html

# Healthcheck (optional)
# HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -fsS http://localhost/ || exit 1
