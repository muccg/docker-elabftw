FROM ubuntu:16.04
MAINTAINER https://github.com/muccg/docker-elabftw

# install nginx and php-fpm
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    php7.0-fpm \
    php7.0-common \
    php7.0-mysql \
    php7.0-gd \
    php7.0-curl \
    php7.0-bz2 \
    php7.0-zip \
    php-dompdf \
    php7.0-mbstring \
    php7.0-xml \
    php7.0-mcrypt \
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

RUN cd /elabftw \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && ./composer.phar install --no-dev


# start
CMD ["/start.sh"]

# define mountable directories.
VOLUME ["/var/log/nginx", "/elabftw/uploads"]
