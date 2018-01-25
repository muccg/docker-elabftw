FROM ubuntu:16.04
MAINTAINER https://github.com/muccg/docker-elabftw

# install nginx and php-fpm
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    php7.0-fpm \
    php7.0-mysql \
    php7.0-gd \
    php7.0-curl \
    curl \
    git \
    unzip \
    supervisor \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN env --unset=DEBIAN_FRONTEND

# add files
ADD ./nginx80.conf /etc/nginx/sites-available/default
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start.sh /start.sh

# elabftw
RUN git clone --depth 1 -b 1.8.2 https://github.com/elabftw/elabftw.git /elabftw

# start
CMD ["/start.sh"]

# define mountable directories.
VOLUME ["/var/log/nginx", "/elabftw/uploads"]
