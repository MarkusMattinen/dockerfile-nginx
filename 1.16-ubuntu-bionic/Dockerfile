# nginx, confd and supervisord on Ubuntu Bionic
#
# Additional nginx modules included:
# - headers_more
# - dav_ext
#
# To use: add application-specific settings in /etc/nginx/server.conf
# (included from /etc/nginx/nginx.conf inside http context)
#

FROM markusma/confd:0.16-ubuntu-bionic

ENV NGINX_VERSION 1.16.1

RUN add-apt-repository --enable-source ppa:nginx/stable \
 && apt-get update \
 && apt-get build-dep -o APT::Get::Build-Dep-Automatic=true -y nginx=$NGINX_VERSION

RUN cd /tmp \
 && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
 && tar xzf nginx-$NGINX_VERSION.tar.gz \
 && rm nginx-$NGINX_VERSION.tar.gz

ENV HEADERS_MORE_VERSION 0.33
ENV DAV_EXT_VERSION 3.0.0

RUN mkdir -p /tmp/nginx-$NGINX_VERSION/modules \
 && cd /tmp/nginx-$NGINX_VERSION/modules \
 && wget https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz -O headers-more-$HEADERS_MORE_VERSION.tar.gz \
 && tar xzf headers-more-$HEADERS_MORE_VERSION.tar.gz \
 && wget https://github.com/arut/nginx-dav-ext-module/archive/v$DAV_EXT_VERSION.tar.gz -O nginx-dav-ext-module-$DAV_EXT_VERSION.tar.gz \
 && tar xzf nginx-dav-ext-module-$DAV_EXT_VERSION.tar.gz

RUN cd /tmp/nginx-$NGINX_VERSION \
 && sed -i "s/#define NGX_HTTP_AUTOINDEX_NAME_LEN.*/#define NGX_HTTP_AUTOINDEX_NAME_LEN 200/g" src/http/modules/ngx_http_autoindex_module.c

RUN cd /tmp/nginx-$NGINX_VERSION \
 && ./configure \
    --add-module=modules/headers-more-nginx-module-$HEADERS_MORE_VERSION \
    --add-module=modules/nginx-dav-ext-module-$DAV_EXT_VERSION \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --group=www-data \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-log-path=/var/log/nginx/access.log \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --user=www-data \
    --with-debug \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module \
    --with-http_mp4_module \
    --with-http_perl_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-pcre-jit \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
 && make -j`nproc` \
 && make install \
 && cd /tmp \
 && rm -rf nginx-$NGINX_VERSION.tar.gz nginx-$NGINX_VERSION \
 && apt-get autoremove -y --purge -o APT::AutoRemove::RecommendsImportant=false \
 && apt-get install -y --no-install-recommends libxslt1.1 libxml2 libgeoip1 libgd3 perl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/lib/nginx/body /var/lib/nginx/proxy /var/lib/nginx/fastcgi /var/lib/nginx/scgi /var/lib/nginx/uwsgi \
 && chown -R www-data:www-data /var/lib/nginx

COPY etc/ /etc/
