FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

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
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libsodium-dev \
    libssl-dev     

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd sodium zip
RUN docker-php-ext-enable pdo_mysql

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Remove Cache
RUN rm -rf /var/cache/apk/*

# Create system user to run Composer and Artisan Commands
RUN mkdir -p /home/docker/.composer && \
    chown -R docker:docker /home/docker
RUN chown -R www-data:www-data /var/www/

USER docker

CMD /bin/bash