FROM nginx:alpine

# 环境变量配置
ENV LISTEN_PORT=80 \
    SERVER_NAME=localhost \
    PROXY_PASS_URL="" \
    PROXY_LOCATION=/api/ \
    ROOT_PATH=/usr/share/nginx/html \
    INDEX_FILE=index.html

# 创建启动脚本，用于根据环境变量生成nginx配置
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 生成nginx配置文件' >> /docker-entrypoint.sh && \
    echo 'cat > /etc/nginx/conf.d/default.conf << EOF' >> /docker-entrypoint.sh && \
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
    echo '    # 反向代理配置（如果设置了PROXY_PASS_URL）' >> /docker-entrypoint.sh && \
    echo '    location ${PROXY_LOCATION} {' >> /docker-entrypoint.sh && \
    echo '        proxy_pass \${PROXY_PASS_URL};' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header Host \$host;' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header X-Real-IP \$remote_addr;' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' >> /docker-entrypoint.sh && \
    echo '        proxy_set_header X-Forwarded-Proto \$scheme;' >> /docker-entrypoint.sh && \
    echo '    }' >> /docker-entrypoint.sh && \
    echo '}' >> /docker-entrypoint.sh && \
    echo 'EOF' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 替换环境变量' >> /docker-entrypoint.sh && \
    echo 'envsubst < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp' >> /docker-entrypoint.sh && \
    echo 'mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# 如果没有设置反向代理URL，则删除反向代理配置' >> /docker-entrypoint.sh && \
    echo 'if [ -z "$PROXY_PASS_URL" ]; then' >> /docker-entrypoint.sh && \
    echo '    sed -i "/# 反向代理配置/,/}/d" /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
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