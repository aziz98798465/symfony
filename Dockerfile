FROM php:8.2-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libpq-dev \
    libicu-dev \
    libzip-dev \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        intl \
        zip

# Enable Apache rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project
COPY . .

# Install Symfony dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Apache public folder
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf

# Create Symfony folders
RUN mkdir -p \
    var/cache \
    var/log \
    public/uploads

# Permissions
RUN chown -R www-data:www-data /var/www/html

RUN chmod -R 777 var
RUN chmod -R 777 public/uploads

# Clear cache
RUN php bin/console cache:clear --env=prod || true

EXPOSE 80

CMD chmod -R 777 var && php bin/console doctrine:schema:update --force --no-interaction || true && apache2-foreground