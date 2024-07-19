# MFProxy

MFProxy 是一个基于 [OpenResty](https://openresty.org/) 和 [ngx_http_proxy_connect_module](https://github.com/chobits/ngx_http_proxy_connect_module) 模块的 HTTP/HTTPS 正向代理

该代理支持 HTTP 基本认证（Basic Authentication）

## 1. 使用

开始使用前请确保您的系统已经安装了 Docker

如果没有, 请参文档 [Install Docker Engine | Docker Docs](https://docs.docker.com/engine/install/) ,根据您的操作系统版本安装 Docker


### 1.1 构建镜像

```shell
# 为 build.sh 授予执行权限
chmod +x ./build.sh

# 执行构建脚本
./build.sh
```

构建脚本将从 `version.txt` 文件读取版本号并进行镜像构建

> 注意：构建脚本会在构建前删除版本号相同的镜像


如果您使用的是非 Linux 系统或者想手动构建镜像，可以手动执行 `build.sh` 命令

```shell
# {{image_name}}: 镜像名称，例如 mfproxy:0.0.1

# 删除已有镜像
docker rmi {{image_name}}

# 构建镜像
docker build -t {{image_name}} --no-cache .
```

如果构建成功，你将会得到一个名称为 `mfproxy:{{version}}` 的 Docker 镜像

您可以使用 `docker images` 命令查看镜像列表

```shell
mf@mf:~$ docker images
REPOSITORY                            TAG              IMAGE ID       CREATED         SIZE
mfproxy                               v0.0.1           6298dea2807d   17 hours ago    618MB
.....
```


### 1.2 启动代理

`mfproxy` 通过 **8000** 端口对外提供 http/https 代理服务

您可以使用以下命令启动一个 `mfproxy` 容器

```shell
docker run -d -p 8000:8000 --name mfproxy mfproxy:v0.0.1
```

这个命令使用 docker 的 run 子命令，基于 `mfproxy:v0.0.1` 镜像运行一个新的容器，名称指定为 `mfproxy`。同时将容器的 8000 端口映射到主机的 8000 端口

- `-d`: 运行容器并进入后台运行
- `-p`: 将容器的 8000 端口映射到主机的 8000 端口
- `--name`: 指定容器名称

当容器启动后，您可以通过使用网络请求工具来测试代理是否正常，例如使用 `curl`

> 代理默认配置的认证用户是 mfproxy:mfproxy

```shell
curl --proxy mfproxy:mfproxy@127.0.0.1:8000 https://www.baidu.com
```


### 1.3 代理配置

mfproxy 容器的所有配置和数据都存储在 /root/mfproxy/ 中，你可以使用 -v 将容器内的配置目录挂载到主机的目录下，通过修改配置来实现代理自定义配置

您可以在启动代理容器时加上 -v 参数

```shell
docker run -d -p 8000:8000 --name mfproxy -v {{path}}:/root/mfproxy mfproxy:v0.0.1
```

- `{{path}}`: 宿主机的本地路径，即要存储 mfproxy 容器配置的目录路径



#### 1.3.1 认证配置

mfproxy 通过基本认证（Basic Authentication）要对用户实现认证，所以，认证配置基本上和配置 Nginx 的 Basic Authentication 是一样的。

但是为了更加容易使用，mfproxy 提供了纯文本的配置方式来配置认证信息

通过编辑 *{{path}}/conf/auth.txt* 文本文件，即可实现代理认证用户的 新增、删除、修改

该文件的每一个行都是一个用户认证配置，格式为：`用户名:密码`

修改认证配置后，您需要重启容器才能使其生效

```shell
docker restart mfproxy
```


#### 1.3.2 取消认证

> 暴露在公网的代理，不建议取消认证

如果您需要取消代理的认证功能，可以在 *{{path}}/conf/nginx.conf* 配置文件中，将 Basic Authentication 认证相关的配置删除或者注释掉

```conf
...

http {
    ...

    server {
        ...
        # 删除或者注释这两行
        auth_basic                     "Proxy server auth";
        auth_basic_user_file           htpasswd;
        ...
    }
}
```


#### 1.3.3 修改 DNS

mfproxy 配置了常用的国内外公共 DNS，一般情况下不需要修改，但是某些情况下您可能需要自定义 DNS 服务器地址。

如果您需要配置DNS服务器，可以在 *{{path}}/conf/nginx.conf* 配置文件中

```conf
...

http {
    ...

    server {
        ...
        # 修改 DNS 服务器地址
        resolver                       114.114.114.114 223.5.5.5 8.8.8.8 1.1.1.1 ipv6=off;
        ...
    }
}
```