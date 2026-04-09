FROM debian:bookworm

RUN apt-get update -y && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

COPY conf/my_config.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]