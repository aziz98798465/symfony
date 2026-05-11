FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libpq-dev \
    libicu-dev \
    && docker-php-ext-install pdo pdo_pgsql intl

# Enable Apache rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project
COPY . .

# Install Symfony dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Apache config
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf

# Create Symfony folders
RUN mkdir -p var/cache var/log

# Permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 775 var
RUN chmod -R 775 public

# Use www-data user
USER www-data

EXPOSE 80

CMD php bin/console doctrine:schema:update --force && apache2-foreground