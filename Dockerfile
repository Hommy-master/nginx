FROM nginx:alpine

# 安装 gettext 用于 envsubst
RUN apk add --no-cache gettext

# 环境变量配置
ENV LISTEN_PORT=80 \
    SERVER_NAME=localhost \
    ROOT_PATH=/usr/share/nginx/html \
    INDEX_FILE=index.html

# 创建启动脚本，用于根据环境变量生成nginx配置
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 生成nginx配置文件' >> /docker-entrypoint.sh && \
    echo 'cat > /etc/nginx/conf.d/default.conf << NGINXCONF' >> /docker-entrypoint.sh && \
    echo 'server {' >> /docker-entrypoint.sh && \
    echo '    listen ${LISTEN_PORT};' >> /docker-entrypoint.sh && \
    echo '    server_name ${SERVER_NAME};' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    location / {' >> /docker-entrypoint.sh && \
    echo '        root ${ROOT_PATH};' >> /docker-entrypoint.sh && \
    echo '        index ${INDEX_FILE};' >> /docker-entrypoint.sh && \
    echo '        try_files \$uri \$uri/ =404;' >> /docker-entrypoint.sh && \
    echo '    }' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    # DYNAMIC_PROXY_LOCATIONS' >> /docker-entrypoint.sh && \
    echo '}' >> /docker-entrypoint.sh && \
    echo 'NGINXCONF' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 处理多个反向代理配置' >> /docker-entrypoint.sh && \
    echo 'i=1' >> /docker-entrypoint.sh && \
    echo 'while true; do' >> /docker-entrypoint.sh && \
    echo '    eval PROXY_URL=\$PROXY_PASS_URL_$i' >> /docker-entrypoint.sh && \
    echo '    eval PROXY_LOC=\$PROXY_LOCATION_$i' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    if [ -z "$PROXY_URL" ]; then' >> /docker-entrypoint.sh && \
    echo '        break' >> /docker-entrypoint.sh && \
    echo '    fi' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    LOC="${PROXY_LOC:-/api/}"' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    # 追加反向代理配置到临时文件' >> /docker-entrypoint.sh && \
    echo '    cat >> /tmp/proxy.conf << PROXYBLOCK' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    location __LOC__ {' >> /docker-entrypoint.sh && \
    echo '        proxy_pass __URL__;' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header Host \$host;' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header X-Real-IP \$remote_addr;' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header X-Forwarded-Proto \$scheme;' >> /docker-entrypoint.sh && \
    echo '    }' >> /docker-entrypoint.sh && \
    echo 'PROXYBLOCK' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    # 替换占位符' >> /docker-entrypoint.sh && \
    echo '    sed -i "s|__LOC__|$LOC|g" /tmp/proxy.conf' >> /docker-entrypoint.sh && \
    echo '    sed -i "s|__URL__|$PROXY_URL|g" /tmp/proxy.conf' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '    i=$((i + 1))' >> /docker-entrypoint.sh && \
    echo 'done' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 将反向代理配置插入到配置文件中' >> /docker-entrypoint.sh && \
    echo 'if [ -f /tmp/proxy.conf ]; then' >> /docker-entrypoint.sh && \
    echo '    sed -i "/# DYNAMIC_PROXY_LOCATIONS/r /tmp/proxy.conf" /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo '    rm -f /tmp/proxy.conf' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 删除占位符' >> /docker-entrypoint.sh && \
    echo 'sed -i "/# DYNAMIC_PROXY_LOCATIONS/d" /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 替换环境变量（只替换指定的变量，保留nginx变量如$host等）' >> /docker-entrypoint.sh && \
    echo 'envsubst '\''${LISTEN_PORT},${SERVER_NAME},${ROOT_PATH},${INDEX_FILE}'\'' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp' >> /docker-entrypoint.sh && \
    echo 'mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo 'echo "Nginx配置:"' >> /docker-entrypoint.sh && \
    echo 'cat /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo 'exec "$@"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# 创建默认首页
RUN echo '<!DOCTYPE html>' > /usr/share/nginx/html/index.html && \
    echo '<html><head><title>Welcome to nginx!</title></head>' >> /usr/share/nginx/html/index.html && \
    echo '<body><h1>Welcome to nginx!</h1>' >> /usr/share/nginx/html/index.html && \
    echo '<p>If you see this page, the nginx web server is successfully installed and working.</p></body></html>' >> /usr/share/nginx/html/index.html

# 暴露端口（使用环境变量，但EXPOSE指令只作文档说明）
EXPOSE 80

# 设置入口脚本
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]