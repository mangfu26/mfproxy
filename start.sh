#!/bin/bash

nginx_directory="/usr/local/openresty/nginx"
nginx_prefix_directory="/root/mfproxy"
source_nginx_prefix_directory="/root/.mfproxy"
htpasswd_file="$nginx_prefix_directory/conf/htpasswd"
auth_file="$nginx_prefix_directory/conf/auth.txt"

# 初始化 Nginx 的工作目录
mkdir -p $nginx_prefix_directory
cp -ru $source_nginx_prefix_directory/* $nginx_prefix_directory/

# 为 Nginx 生成密码文件
rm -f $htpasswd_file
touch $htpasswd_file
while IFS=: read -r user pass; do
    if [[ -z $user ]] || [[ -z $pass ]]; then
        continue
    fi
    htpasswd -b -m $htpasswd_file "$user" "$pass"
done < $auth_file

if [[ -n $user ]] && [[ -n $pass ]]; then
    htpasswd -b -m $htpasswd_file "$user" "$pass"
fi

$nginx_directory/sbin/nginx -c $nginx_prefix_directory/conf/nginx.conf -t
$nginx_directory/sbin/nginx -p $nginx_prefix_directory -c $nginx_prefix_directory/conf/nginx.conf