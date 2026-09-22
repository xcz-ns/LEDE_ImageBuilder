# LEDE ImageBuilder 固件自动构建

基于 GitHub Actions + OpenWrt ImageBuilder 的多设备固件自动构建项目。从 [xcz-ns/LEDE](https://github.com/xcz-ns/LEDE) 的 Release 中下载预编译 ImageBuilder，通过自定义软件包和文件定制固件，自动发布到 GitHub Releases。

## 支持的设备

| 设备目录 | 目标平台 | 子平台 | Profile |
|---|---|---|---|
| `LEDE_Cudy` | mediatek | filogic | cudy_tr3000-mod |
| `LEDE_R3S` | rockchip | armv8 | friendlyarm_nanopi-r3s |
| `LEDE_x86` | x86 | 64 | generic |

## 目录结构

```
├── .github/workflows/
│   ├── build-image.yml    # 固件构建工作流
│   └── cleanup.yml         # 历史 Release / 运行记录清理
├── LEDE_Cudy/              # Cudy TR3000 设备配置
│   ├── custom.sh           # 自定义二进制下载脚本（lucky）
│   ├── packages.txt        # 要移除的软件包列表（-开头）
│   ├── packages/           # 本地 ipk 软件包
│   └── files/              # 自定义文件（直接覆盖到根文件系统）
├── LEDE_R3S/               # NanoPi R3S 设备配置
└── LEDE_x86/               # x86_64 设备配置
```

## 使用方法

### 手动触发构建

1. 进入仓库的 **Actions** 页面
2. 选择 **OpenWrt 固件构建** 工作流
3. 点击 **Run workflow**
4. 选择要构建的设备（可选单个设备或 `all`）
5. 等待构建完成，固件会自动发布到 **Releases**

### 全部设备构建

选择 `all` 时，三个设备会在同一 concurrency 组中**串行构建**，避免 Release tag 冲突。每个设备构建完成后独立发布 Release。

## 自定义配置

### packages.txt

每行一个包名，以 `-` 开头表示从固件中**移除**该包。例如：

```
-luci-app-samba
-procd-seccomp
```

### files/ 目录

该目录下的文件会在构建时直接覆盖到固件的根文件系统。例如：
- `files/etc/config/network` → 固件中的 `/etc/config/network`
- `files/usr/bin/lucky` → 固件中的 `/usr/bin/lucky`

### custom.sh

构建时自动执行的自定义脚本，通常用于下载第三方预编译二进制文件（如 lucky、filebrowser、OpenClash 内核等）。脚本在仓库根目录下执行，可通过 `$DEVICE` 环境变量获取当前设备名。

**注意**：下载的文件必须放到 `$DEVICE/files/` 目录下，才会被打包进固件。

## 历史清理

`cleanup.yml` 工作流会在每次构建完成后自动触发（也可手动触发）：
- 每个设备各自保留最新 **2** 个 Release，更早的自动删除
- 保留最新 **2** 条 build-image 运行记录
- 手动触发时额外删除全部失败的运行记录
- cleanup 自身的运行记录不保留

## 注意事项

- ImageBuilder 来源于 [xcz-ns/LEDE](https://github.com/xcz-ns/LEDE) 的 Release，需确保对应设备的 Release 已发布
- `packages/` 目录中的本地 ipk 会被自动加入固件，无需在 `packages.txt` 中声明
- 构建超时时间为 120 分钟
