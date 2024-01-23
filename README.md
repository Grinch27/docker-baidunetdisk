# docker-baidunetdisk

[![Pulls](https://img.shields.io/docker/pulls/grinch27/baidunetdisk)](https://hub.docker.com/r/grinch27/baidunetdisk)
[![Stars](https://img.shields.io/github/stars/Grinch27/docker-baidunetdisk?style=flat)](https://github.com/Grinch27/docker-baidunetdisk)

这是一个用于自我学习的 Baidunetdisk 容器项目。

Baidunetdisk Container for self learning

## 项目介绍

这个项目是一个 Docker 容器，其中包含了 Baidunetdisk。它可以帮助你在任何支持 Docker 的平台上运行 Baidunetdisk，无论是在本地机器上，还是在云服务器上。

镜像基于 [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui) debian-11-v4.5.3 镜像进行构建

参考 [gshang2017/docker](https://github.com/gshang2017/docker) 代码，使用 --no-install-recommends 参数进行安装减少镜像大小。

个人使用在arm64 Openwrt系统环境，体验感受：从镜像大小上看，相比未使用 --no-install-recommends，镜像大小从约 700MB 减少到约 600MB。在amd64 Docker Desktop中能够成功运行容器。

注意：由于 [releases v4.3.0](https://github.com/jlesage/docker-baseimage-gui/releases/tag/v4.3.0) 文中提到Openbox替代了jwm，在Dockerfile文件中添加了与openbox相关的设置。

## 使用 Docker 运行百度网盘

你可以使用以下的 Docker 命令或者 Docker Compose 配置来运行百度网盘。

### Docker 命令

以下的命令会创建一个名为 `baidunetdisk` 的 Docker 容器，并将 5800 和 5900 端口映射到主机上：

```bash
docker create \
    --name=baidunetdisk \
    -p 5800:5800 \
    -p 5900:5900 \
    -v /config-path:/config \
    -v /download-path:/config/baidunetdiskdownload \
    --restart unless-stopped \
    grinch27/baidunetdisk:latest
```

请将 `/config-path` 和 `/download-path` 替换为你的配置文件和下载文件的实际路径。

### Docker Compose

以下是一个 Docker Compose 的配置示例：

```yaml
version: "3.8"

services:
  baidunetdisk:
    image: grinch27/baidunetdisk:latest
    container_name: baidunetdisk
    restart: unless-stopped
    network_mode: host
    extra_hosts:
      - "update.pan.baidu.com:127.0.0.1"
    environment:
      VNC_PASSWORD: password
      WEB_LISTENING_PORT: "5800"
      VNC_LISTENING_PORT: "5900"
      DISPLAY_WIDTH: "1920"
      DISPLAY_HEIGHT: "1080"
      LANGUAGE: "zh_CN.UTF-8"
      LANG: "zh_CN.UTF-8"
    volumes:
      - /config-path:/config:rw
      - /download-path:/config/baidunetdiskdownload:rw
    logging:
      driver: "json-file"
      options:
        max-size: "1m"
        max-file: "2"
```

请将 `/config-path` 和 `/download-path` 替换为你的配置文件和下载文件的实际路径。

然后，你可以使用以下的命令来启动你的 Docker Compose 配置：

```bash
VNC_PASSWORD=password docker compose -f /path-to-your-docker-compose-file/docker-compose.yml up -d
```

在这个命令中，你需要将 /path-to-your-docker-compose-file 替换为你的 docker-compose.yml 文件的实际路径。VNC_PASSWORD=password 设置了 VNC_PASSWORD 环境变量的值为 password，你可以将 password 替换为你的实际密码。

然后，你可以在浏览器中访问 `http://localhost:5800` 来使用 Baidunetdisk。

## 参考与感谢

这个项目参考了以下项目，并对他们表示感谢：

- [jlesage/docker-baseimage-gui](https://github.com/jlesage/docker-baseimage-gui)
- [gshang2017/docker](https://github.com/gshang2017/docker)