FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    libzip-dev \
    zip \
    unzip \
    build-essential \
    default-mysql-client \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libsodium-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    libssl-dev     

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd sodium zip
RUN docker-php-ext-enable pdo_mysql
RUN docker-php-ext-configure gd --with-freetype --with-jpeg 

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

USER www

# Expose port 9000 and start php-fpm server
EXPOSE 8080
CMD ["php-fpm"]