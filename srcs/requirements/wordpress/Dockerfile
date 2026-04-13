FROM debian:bookworm

RUN apt-get update -y && apt-get install -y \
    php-fpm \
    php-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

