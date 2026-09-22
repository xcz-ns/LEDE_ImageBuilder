#!/bin/bash

cd ..

# 全局路径与架构定义
BIN_DIR="$DEVICE/files/usr/bin"
CORE_DIR="$DEVICE/files/etc/openclash/core"
ARCH_AMD64="amd64"
ARCH_X86_64="x86_64"

mkdir -p "$BIN_DIR" "$CORE_DIR"

# ==============================================================================
# 1. 下载并配置 OpenClash Meta 内核 (amd64)
# ==============================================================================
OPENCLASH_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-${ARCH_AMD64}.tar.gz"

echo "----------------------------------------------------"
echo "[1/3] 正在解析 OpenClash Meta 版本信息..."
echo "✅ 成功匹配: $OPENCLASH_URL"
echo "开始下载并提取二进制..."

if wget -qO- --tries=3 --timeout=15 "$OPENCLASH_URL" \
    | tar -xz -C "$CORE_DIR"; then
    
    mv -f "$CORE_DIR/clash" "$CORE_DIR/clash_meta"
    chmod +x "$CORE_DIR/clash_meta"
    
    echo "🎉 完成：已成功提取到 $CORE_DIR/clash_meta"
    ls -lh "$CORE_DIR/clash_meta"
else
    echo "❌ 下载或解压失败"
    exit 1
fi

# ==============================================================================
# 2. 下载并配置 Filebrowser 二进制文件 (amd64)
# ==============================================================================
FB_REPO="filebrowser/filebrowser"
FB_ARCH_KEY="linux-${ARCH_AMD64}-filebrowser.tar.gz"

echo "----------------------------------------------------"
echo "[2/3] 正在解析 Filebrowser 版本信息..."

# 优先通过 GitHub API 解析下载地址
FB_URL=$(curl -sL "https://api.github.com/repos/$FB_REPO/releases/latest" \
    | grep -o "https://[^\"]*${FB_ARCH_KEY}" \
    | head -n 1)

# API 达到调用限制时的回退解析方案
if [ -z "$FB_URL" ]; then
    LATEST_TAG=$(curl -sIL -o /dev/null -w '%{url_effective}' "https://github.com/$FB_REPO/releases/latest" \
        | sed 's#.*/##')
    
    [ -n "$LATEST_TAG" ] && FB_URL="https://github.com/$FB_REPO/releases/download/$LATEST_TAG/linux-${ARCH_AMD64}-filebrowser.tar.gz"
fi

[ -z "$FB_URL" ] && { 
    echo "❌ 获取版本失败"
    exit 1
}

echo "✅ 成功匹配: $FB_URL"
echo "开始下载并提取二进制..."

if curl -sL --connect-timeout 15 "$FB_URL" \
    | tar -xz -C "$BIN_DIR" filebrowser; then
    
    chmod +x "$BIN_DIR/filebrowser"
    
    echo "🎉 完成：已成功提取到 $BIN_DIR/filebrowser"
    ls -lh "$BIN_DIR/filebrowser"
else
    echo "❌ 下载或解压失败"
    exit 1
fi

# ==============================================================================
# 3. 下载并配置 Lucky 二进制文件 (x86_64)
# ==============================================================================
LUCKY_BASE="https://release.66666.host"

echo "----------------------------------------------------"
echo "[3/3] 正在解析 Lucky 版本信息..."

# 解析版本号
LUCKY_VER=$(curl -sL "$LUCKY_BASE/" \
    | grep -o 'href="\./v[^/]*' \
    | cut -d/ -f2 \
    | sort -rV \
    | head -1)

[ -z "$LUCKY_VER" ] && { 
    echo "❌ 获取版本失败"
    exit 1
}

# 解析子目录
LUCKY_SUB=$(curl -sL "$LUCKY_BASE/$LUCKY_VER/" \
    | grep -o 'href="\./[^/]*' \
    | cut -d/ -f2 \
    | grep -i '^[0-9].*lucky' \
    | head -1)

[ -z "$LUCKY_SUB" ] && { 
    echo "❌ 未找到 lucky 子目录"
    exit 1
}

# 匹配目标架构安装包
LUCKY_PKG=$(curl -sL "$LUCKY_BASE/$LUCKY_VER/$LUCKY_SUB/" \
    | grep -o 'href="[^"]*' \
    | cut -d'"' -f2 \
    | grep -i "Linux.*$ARCH_X86_64.*\.tar\.gz" \
    | head -1)

[ -z "$LUCKY_PKG" ] && { 
    echo "❌ 未找到 $ARCH_X86_64 包"
    exit 1
}

echo "✅ 成功匹配: $LUCKY_VER / $LUCKY_PKG"
echo "开始下载并提取二进制..."

if curl -sL --connect-timeout 10 "$LUCKY_BASE/$LUCKY_VER/$LUCKY_SUB/$LUCKY_PKG" \
    | tar -xz -C "$BIN_DIR" lucky; then
    
    chmod +x "$BIN_DIR/lucky"
    
    echo "🎉 完成：已成功提取到 $BIN_DIR/lucky"
    ls -lh "$BIN_DIR/lucky"
else
    echo "❌ 下载或解压失败"
    exit 1
fi
