FROM php:8.4-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    # build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    # locales \
    zip \
    # jpegoptim optipng pngquant gifsicle \
    # vim \
    unzip \
    # git \
    # curl \
    libzip-dev \
    # apt-utils \
    libonig-dev \
    libpq-dev \
    libssl-dev \
    # pkg-config \
    && docker-php-ext-install pdo_pgsql zip mbstring exif \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# RUN groupadd -g 1000 developer && useradd -u 1000 -ms /bin/bash -g developer user

# COPY --chown=user:developer . /var/www

# RUN mkdir -p /var/www/assets/uploads && chown -R www-data /var/www/assets/uploads

# USER user

EXPOSE 9000