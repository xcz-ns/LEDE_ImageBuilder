#!/bin/bash

cd ..

# 下载并配置 lucky 二进制文件
BASE="https://release.66666.host"
DIR="$DEVICE/files/usr/bin"
ARCH="arm64"

mkdir -p "$DIR"

echo "[1/2] 正在解析最新版本信息..."
# 解析最新版本号
VER=$(curl -sL "$BASE/" \
    | grep -o 'href="\./v[^/]*' \
    | cut -d/ -f2 \
    | sort -rV \
    | head -1)
[ -z "$VER" ] && { 
    echo "❌ 获取版本失败"
    exit 1
}

# 解析 lucky 子目录
SUB=$(curl -sL "$BASE/$VER/" \
    | grep -o 'href="\./[^/]*' \
    | cut -d/ -f2 \
    | grep -i '^[0-9].*lucky' \
    | head -1)
[ -z "$SUB" ] && { 
    echo "❌ 未找到 lucky 子目录"
    exit 1
}

# 匹配目标架构安装包
PKG=$(curl -sL "$BASE/$VER/$SUB/" \
    | grep -o 'href="[^"]*' \
    | cut -d'"' -f2 \
    | grep -i "Linux.*$ARCH.*\.tar\.gz" \
    | head -1)
[ -z "$PKG" ] && { 
    echo "❌ 未找到 $ARCH 包"
    exit 1
}
echo "✅ 成功匹配: $VER / $PKG"

echo "[2/2] 开始下载并提取二进制..."
# 下载并解压 lucky 二进制文件
curl -sL --connect-timeout 10 "$BASE/$VER/$SUB/$PKG" \
    | tar -xz -C "$DIR" lucky || { 
        echo "❌ 下载或解压失败"
        exit 1
    }

echo "🎉 完成：已成功提取到 $DIR/lucky"
ls -lh "$DIR/lucky"