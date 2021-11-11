FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

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

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Copy existing application directory permissions
RUN chmod -R 755 /var/www
RUN chown -R ${USER}:www-data /var/www
RUN chown -R ${USER}:www-data /var/www/storage
RUN chown -R ${USER}:www-data /var/www/bootstrap/cache

# Set working directory
WORKDIR /var/www

USER $user

# Copy existing application directory contents
COPY . /var/www

# Expose port 9000 and start php-fpm server
EXPOSE 8080
CMD ["php-fpm"]