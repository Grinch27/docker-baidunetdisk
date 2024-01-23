# docker-baidunetdisk

[![Pulls](https://img.shields.io/docker/pulls/grinch27/baidunetdisk)](https://hub.docker.com/r/grinch27/baidunetdisk)
[![Stars](https://img.shields.io/github/stars/Grinch27/docker-baidunetdisk?style=flat)](https://github.com/Grinch27/docker-baidunetdisk)

这是一个用于自我学习的 Baidunetdisk 容器项目。

Baidunetdisk Container for self learning

## 项目介绍

这个项目是一个 Docker 容器，其中包含了 Baidunetdisk。它可以帮助你在任何支持 Docker 的平台上运行 Baidunetdisk，无论是在本地机器上，还是在云服务器上。

## 使用方法

首先，你需要安装 Docker。然后，你可以使用以下命令来运行这个容器：

```bash
docker run -d --name=baidunetdisk -p 5800:5800 -p 5900:5900 grinch27/baidunetdisk
```

然后，你可以在浏览器中访问 `http://localhost:5800` 来使用 Baidunetdisk。

## 参考与感谢

这个项目参考了以下项目，并对他们表示感谢：

- [jlesage/docker-baseimage-gui](https://github.com/jlesage/docker-baseimage-gui)
- [gshang2017/docker](https://github.com/gshang2017/docker)