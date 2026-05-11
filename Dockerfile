FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libpq-dev \
    libicu-dev \
    libzip-dev \
    && docker-php-ext-install pdo pdo_pgsql zip intl

# Enable Apache rewrite module
RUN a2enmod rewrite

# Fix Apache warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Install Symfony dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Configure Apache for Symfony public folder
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf

RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

# Symfony permissions
RUN mkdir -p var/cache var/log
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 777 var

# Expose Apache port
EXPOSE 80

# Start Symfony + run migrations automatically
CMD php bin/console doctrine:migrations:migrate --no-interaction && apache2-foreground