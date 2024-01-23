#!/bin/bash
set -e

# bash ./baidunetdiskbuild.sh USER/REPO

# 建议设置好DNS，否则可能会导致apt-get update失败
# nano /etc/resolv.conf

# 获取脚本文件的路径
SCRIPT_DIR=$(dirname "$0")
# 转换脚本文件夹下的所有 .sh 文件为 Unix 格式
# find $SCRIPT_DIR/ -type f -name "*.sh" -print0 | xargs -0 dos2unix

# 使用脚本文件夹下的 Dockerfile 文件构建镜像
# dockerhub repo
HUB_REPO=$1
# HUB_TAG="debian-11-slim"
# Build
# PLATFORM="linux/arm64"
# baseimage
BASEIMAGE_OS="debian-11"
BASEIMAGE_VER="v4.5.3"
# apt
APT_SRC="deb.debian.org" # mirrors.tuna.tsinghua.edu.cn    mirrors.ustc.edu.cn   deb.debian.org
APT_OS_VER="bullseye"
APT_SLIM="true"
APT_PACKAGES=(
    "libasound2" # 音频库
    "libgbm1" # 图形库
    "libgtk-3-0" # GUI 库
    "libnss3" # 网络安全服务库
    "libxss1" # X11 屏幕保护库
    "desktop-file-utils" # 桌面文件工具
    "libnotify4" # 通知库
    "xdg-utils" # XDG 工具
    "libsecret-common" # 密码库
    "libsecret-1-0" # 密码库
    # "ibindicator3-7" # 应用指示器库
    "libdbusmenu-glib4" # DBus 菜单库
    "libdbusmenu-gtk3-4" # DBus 菜单库
    "libappindicator3-1" # 应用指示器库
    "ttf-wqy-zenhei" # 文泉驿正黑字体
    "procps" # 进程查看工具
    "wget" # 网络下载工具
    # "ca-certificates" # CA 证书
    "libxtst6" # X11 测试工具库
    "libx11-xcb1" # X11 XCB 库
    "x11-xserver-utils" # X11 服务器工具
)
APT_PACKAGES_STR=$(IFS=' '; echo "${APT_PACKAGES[*]}")
# app
APP_VER="4.17.7"
APP_PLATFORM="arm64"
# ENV
ENV_LANG="zh_CN.UTF-8"
ENV_TZ="Asia/Shanghai"
ENV_PLATFORM_DOCKER=$PLATFORM


# 定义全局变量
IMAGE_PLATFORMS=("linux/arm64" "linux/amd64")
IMAGE_TAGS=("latest") #"slim"
BASEIMAGE_VER="v4.5.3"
APT_SLIM="true"

# 构建镜像的函数
build_image() {
    local platform=$1
    local tag=$2
    local baseimage_os=$3
    local apt_os_ver=$4
    local app_platform=$(echo $platform | cut -d '/' -f 2)

    docker buildx build -f $SCRIPT_DIR/Dockerfile \
        --platform $platform \
        --build-arg BASEIMAGE_OS=$baseimage_os \
        --build-arg BASEIMAGE_VER=$BASEIMAGE_VER \
        --build-arg APT_SRC=$APT_SRC \
        --build-arg APT_OS_VER=$apt_os_ver \
        --build-arg APT_SLIM=$APT_SLIM \
        --build-arg APT_PACKAGES="$APT_PACKAGES_STR" \
        --build-arg APP_VER=$APP_VER \
        --build-arg APP_PLATFORM=$app_platform \
        --build-arg ENV_LANG=$ENV_LANG \
        --build-arg ENV_TZ=$ENV_TZ \
        --build-arg ENV_PLATFORM_DOCKER=$platform \
        --tag "$HUB_REPO:$tag-$app_platform" \
        --load .
}

# 为特定标签构建并推送镜像的函数
build_and_push_images_for_tag() {
    local image_tag=$1
    local baseimage_os="debian-11"
    local apt_os_ver="bullseye"

    if [ "$image_tag" == "slim" ]; then
        baseimage_os="debian-10"
        apt_os_ver="buster"
    else
        baseimage_os="debian-11"
        apt_os_ver="bullseye"
    fi

    for image_platform in ${IMAGE_PLATFORMS[@]}
    do
        # 构建镜像
        build_image $image_platform $image_tag $baseimage_os $apt_os_ver

        # 推送镜像
        local app_platform=$(echo $image_platform | cut -d '/' -f 2)
        docker push "$HUB_REPO:$image_tag-$app_platform"
    done
}

create_manifest() {
    local tag=$1

    # 预先计算所有的app_platform
    local app_platforms=(${IMAGE_PLATFORMS[@]#*/})
    local first_platform=${app_platforms[0]}
    local repo_tag=$HUB_REPO:$tag

    # 创建或修改一个包含至少一个镜像的manifest列表
    docker manifest create --amend $repo_tag $repo_tag-$first_platform

    app_platforms=(${app_platforms[@]/#/$repo_tag-})

    # 循环添加其他平台的镜像到manifest列表
    for app_platform in ${app_platforms[@]:1}
    do
        docker manifest annotate $repo_tag $app_platform --os linux --arch ${app_platform#*-}
    done

    # 推送manifest列表
    docker manifest push $repo_tag
}

# 构建并推送镜像的函数
build_and_push_images() {
    for image_tag in ${IMAGE_TAGS[@]}
    do
        build_and_push_images_for_tag $image_tag
        create_manifest $image_tag
        docker system prune -a -f --volumes
    done
}

# 调用函数
build_and_push_images

echo "### [CLEANING UP] ###"
docker system prune -a -f --volumes
