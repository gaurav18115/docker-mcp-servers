FROM node:20-alpine

RUN apk add --no-cache git

# Install supergateway and clone the servers repository
RUN npm install -g supergateway \
    && git clone https://github.com/modelcontextprotocol/servers.git /tmp/servers \
    && cd /tmp/servers \
    && npm install \
    && npm run build \
    && npm install -g . \
    && rm -rf /tmp/servers

EXPOSE 8807

CMD ["supergateway", "--stdio", "mcp-server-everything", "--port", "8807", "--ssePath", "/sse"] 