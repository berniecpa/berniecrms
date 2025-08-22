# Use Webdevops image which has IMAP pre-installed
FROM webdevops/php-apache:8.1

# Everything is already installed! Just add your code
WORKDIR /app

# Copy application files
COPY . .

# Fix permissions
RUN chown -R application:application /app

# The webdevops image uses port 80 by default
EXPOSE 80