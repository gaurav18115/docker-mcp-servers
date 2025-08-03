FROM node:20-alpine

# Install mcp-proxy and the filesystem server
RUN npm install -g mcp-proxy @modelcontextprotocol/server-filesystem

EXPOSE 8801

CMD ["mcp-proxy", "--port", "8801", "--sseEndpoint", "/sse", "mcp-server-filesystem", "/data"] 