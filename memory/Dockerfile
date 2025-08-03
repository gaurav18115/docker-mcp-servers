FROM node:20-alpine

RUN apk add --no-cache git

# Install mcp-proxy and clone the servers repository
RUN npm install -g mcp-proxy \
    && git clone https://github.com/modelcontextprotocol/servers.git /tmp/servers \
    && cd /tmp/servers \
    && npm install \
    && npm run build \
    && npm install -g . \
    && rm -rf /tmp/servers

EXPOSE 8802

CMD ["mcp-proxy", "--port", "8802", "--sseEndpoint", "/sse", "mcp-server-memory"] 