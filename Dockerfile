# BASEIMAGE old: jlesage/baseimage-gui:debian-10-v4.2.2
ARG BASEIMAGE_OS="debian-11"
ARG BASEIMAGE_VER="v4.5.3"
# Pull base image.
FROM jlesage/baseimage-gui:${BASEIMAGE_OS}-${BASEIMAGE_VER}

# APT
ARG APT_SRC="mirrors.tuna.tsinghua.edu.cn"
ARG APT_OS_VER="bullseye"
ARG APT_SLIM="true"
ARG APT_PACKAGES="libasound2 libgbm1 libgtk-3-0 libnss3 libxss1 desktop-file-utils libnotify4 xdg-utils libsecret-common libsecret-1-0 libdbusmenu-glib4 libdbusmenu-gtk3-4 libappindicator3-1 ttf-wqy-zenhei procps wget ca-certificates libxtst6 libx11-xcb1 x11-xserver-utils"
# APP 
ARG APP_VER="4.17.7"
ARG APP_PLATFORM="arm64"
# ENV
ARG ENV_LANG="zh_CN.UTF-8"
ARG ENV_TZ="Asia/Shanghai"
ARG ENV_PLATFORM_DOCKER="linux/arm64"

# Public Environment Variables:
# Format of the locale is language[_territory][.codeset] such as "en_US.UTF-8"
ENV LANG=${ENV_LANG}
# Etc/UTC, Etc/Universal, Etc/Zulu, ...
ENV TZ=${ENV_TZ}
# Width & Height (in pixels) of the Application's window.
ENV DISPLAY_WIDTH="1920"
ENV DISPLAY_HEIGHT="1080"

# Internal Environment Variables
# Name of the implemented application.
ENV APP_NAME="Baidunetdisk"
# Version of the implemented application.
ENV APP_VERSION=${APP_VER}
# Version of the Docker image that implements the application.
ENV DOCKER_IMAGE_VERSION=${BASEIMAGE_VER}
# Platform (OS / CPU architecture) of the Docker image that implements the application.
ENV DOCKER_IMAGE_PLATFORM=${ENV_PLATFORM_DOCKER}
# Home directory.
ENV HOME=/config

# MISC Environment Variables
# Language of the noVNC web interface.
ENV NOVNC_LANGUAGE="zh_Hans"
# Locale to use. en_US.UTF-8, fr_FR.UTF-8, ...
ENV LC_ALL=C



RUN apt-get update --ignore-missing \
    # set temp apt source & install ca-certificates
    && apt-get install ca-certificates -y --no-install-recommends --fix-missing \
    && echo "deb https://${APT_SRC}/debian/ ${APT_OS_VER} main contrib non-free" > /etc/apt/sources.list \
    && echo "deb-src https://${APT_SRC}/debian/ ${APT_OS_VER} main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb https://${APT_SRC}/debian/ ${APT_OS_VER}-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src https://${APT_SRC}/debian/ ${APT_OS_VER}-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb https://${APT_SRC}/debian/ ${APT_OS_VER}-backports main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src https://${APT_SRC}/debian/ ${APT_OS_VER}-backports main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb https://${APT_SRC}/debian-security/ ${APT_OS_VER}-security main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src https://${APT_SRC}/debian-security/ ${APT_OS_VER}-security main contrib non-free" >> /etc/apt/sources.list \
    # install packages
    && apt-get update --ignore-missing && \
    if [ "${APT_SLIM}" = "true" ]; then \
        apt-get install -y --no-install-recommends --fix-missing $APT_PACKAGES ; \
    else \
        apt-get install -y --fix-missing $APT_PACKAGES ; \
    fi \
    # install baidunetdisk
    && wget https://pkg-ant.baidu.com/issue/netdisk/LinuxGuanjia/${APP_VER}/baidunetdisk_${APP_VER}_${APP_PLATFORM}.deb \
    && dpkg -i  baidunetdisk_${APP_VER}_${APP_PLATFORM}.deb \
    && rm  baidunetdisk_${APP_VER}_${APP_PLATFORM}.deb \
    # clear cache
    && apt-get purge --autoremove -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/*.log

# Clean temp apt source & reset debian apt source
RUN cd / \
    && echo "" > /etc/apt/sources.list \
    && echo "deb https://deb.debian.org/debian/ ${APT_OS_VER} main contrib non-free" > /etc/apt/sources.list \
    && echo "deb-src https://deb.debian.org/debian/ ${APT_OS_VER} main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb https://deb.debian.org/debian/ ${APT_OS_VER}-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src https://deb.debian.org/debian/ ${APT_OS_VER}-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb https://deb.debian.org/debian/ ${APT_OS_VER}-backports main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src https://deb.debian.org/debian/ ${APT_OS_VER}-backports main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb https://deb.debian.org/debian-security ${APT_OS_VER}-security main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src https://deb.debian.org/debian-security ${APT_OS_VER}-security main contrib non-free" >> /etc/apt/sources.list \
    # MISC setup
    && cd / \
    # set /startapp.sh
    && echo "#!/bin/sh\n/opt/baidunetdisk/baidunetdisk --disable-gpu-sandbox --no-sandbox" > /startapp.sh \
    && chmod +x /startapp.sh \
    # openbox
    && mkdir -p /etc/openbox \
    && echo "<Type>normal</Type>\n<Name>Baidunetdisk</Name>" > /etc/openbox/main-window-selection.xml \
    # set /config/.config/mimeapps.list
    && mkdir -p /config/.config \
    && echo "\n[Default Applications]\nx-scheme-handler/baiduyunguanjia=baidunetdisk.desktop" > /config/.config/mimeapps.list \
    && chmod 777 /config/.config/mimeapps.list
