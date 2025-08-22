# Use thecodingmachine PHP image with Apache (includes most extensions)
FROM thecodingmachine/php:8.4-v5-apache

# Set working directory
WORKDIR /var/www/html

# Copy project files to container
COPY . .

# Fix file permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80