# Nginx Docker 镜像

支持通过环境变量灵活配置的 Nginx Docker 镜像。

## 功能特性

- 通过环境变量配置监听端口
- 通过环境变量配置域名
- 通过环境变量配置反向代理
- 基于官方 nginx:alpine 镜像，轻量高效

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `LISTEN_PORT` | 80 | Nginx 监听端口 |
| `SERVER_NAME` | localhost | 服务器域名 |
| `PROXY_PASS_URL` | "" | 反向代理目标地址（为空时不启用反向代理） |
| `PROXY_LOCATION` | /api/ | 反向代理路径 |
| `ROOT_PATH` | /usr/share/nginx/html | 静态文件根目录 |
| `INDEX_FILE` | index.html | 默认首页文件 |
