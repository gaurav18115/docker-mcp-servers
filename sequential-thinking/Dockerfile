FROM node:20-alpine

# Install mcp-proxy and the sequential-thinking server
RUN npm install -g mcp-proxy @modelcontextprotocol/server-sequential-thinking

EXPOSE 8803

CMD ["mcp-proxy", "--port", "8803", "--sseEndpoint", "/sse", "mcp-server-sequential-thinking"] 