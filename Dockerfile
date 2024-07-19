FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root/

COPY . .

RUN apt update && \
    apt install -y libpcre3-dev libssl-dev perl make build-essential zlib1g zlib1g-dev curl patch apache2-utils && \
    tar -xf openresty-1.19.3.1.tar.gz && \
    tar -xf ngx_http_proxy_connect_module-0.0.6.tar.gz

WORKDIR /root/openresty-1.19.3.1/

RUN ./configure --add-module=/root/ngx_http_proxy_connect_module-0.0.6 && \
    patch -d build/nginx-1.19.3/ -p 1 < /root/ngx_http_proxy_connect_module-0.0.6/patch/proxy_connect_rewrite_101504.patch && \
    make && make install

WORKDIR /root/

# RUN cp /usr/local/openresty/nginx/conf/mime.* ./mfproxy/conf/
RUN rm -rf ./ngx_http_proxy_connect_module-0.0.6 && \
    rm -rf ./openresty-1.19.3.1 && \
    rm -f ./openresty-1.19.3.1.tar.gz && \
    rm -f ./ngx_http_proxy_connect_module-0.0.6.tar.gz

CMD [ "bash", "./start.sh" ]