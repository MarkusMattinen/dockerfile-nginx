# nginx, confd and supervisord on trusty
#
# Additional nginx modules included:
# - headers_more
#
# To use: add application-specific settings in /etc/nginx/server.conf
# (included from /etc/nginx/nginx.conf inside http context)
#

FROM markusma/confd:trusty
MAINTAINER Markus Mattinen <docker@gamma.fi>

RUN apt-get update \
 && apt-get build-dep -y nginx \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV NGINX_VERSION 1.5.13
ENV HEADERS_MORE_VERSION 0.25

RUN cd /tmp \
 && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
 && tar xzf nginx-$NGINX_VERSION.tar.gz \
 && cd nginx-$NGINX_VERSION \
 && mkdir -p modules \
 && cd modules \
 && wget https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz -O headers-more-$HEADERS_MORE_VERSION.tar.gz \
 && tar xzf headers-more-$HEADERS_MORE_VERSION.tar.gz \
 && cd .. \
 && ./configure \
    --prefix=/var/www \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-log-path=/var/log/nginx/access.log \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --user=www-data \
    --group=www-data \
    --with-pcre-jit \
    --with-debug \
    --with-http_addition_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_sub_module \
    --with-http_xslt_module \
    --with-ipv6 \
    --with-sha1=/usr/include/openssl \
    --with-md5=/usr/include/openssl \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --without-mail_pop3_module \
    --add-module=modules/headers-more-nginx-module-$HEADERS_MORE_VERSION \
 && make -j`nproc` \
 && make install \
 && cd /tmp \
 && rm -rf nginx-$NGINX_VERSION.tar.gz nginx-$NGINX_VERSION

RUN mkdir -p /var/lib/nginx/body /var/lib/nginx/proxy /var/lib/nginx/fastcgi /var/lib/nginx/scgi /var/lib/nginx/uwsgi \
 && chown -R www-data:www-data /var/lib/nginx

ADD config/etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf