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
    zip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libsodium-dev \
    libssl-dev \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd sodium
RUN docker-php-ext-enable pdo_mysql

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Remove Cache
RUN rm -rf /var/cache/apk/*

EXPOSE 8080
# Create system user to run Composer and Artisan Commands
#RUN useradd -G www-data,root -u ${uid} -d /home/${user} ${user}
#RUN chmod -R ugo+rwx /var/www/storage/
#RUN chmod -R ugo+rwx /var/www/bootstrap/cache/
RUN mkdir -p /home/${user}/.composer && \
    chown -R ${user}:${user} /home/$user
RUN chown -R www-data:www-data /var/www/

USER docker
CMD /bin/bash