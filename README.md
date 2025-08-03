# MCP Servers - Modular Docker Setup

This project runs multiple Model Context Protocol (MCP) servers in separate Docker containers for better modularity and maintainability.

## Architecture

Each MCP server runs in its own container with HTTP/SSE endpoints:
- **filesystem**: File system operations (port 8801) ✅
- **sequential-thinking**: Sequential thinking capabilities (port 8803) ✅
- **git**: Git operations (port 8804) ✅
- **time**: Time-related operations (port 8805) ✅
- **fetch**: HTTP fetch operations (port 8806) ✅
- **memory**: Memory-based operations (port 8802) ⚠️ (executable not found)
- **everything**: Combined server with all capabilities (port 8807) ⚠️ (executable not found)

## Directory Structure

```
mcp-servers/
├── docker-compose.yml          # Orchestrates all services
├── data/                       # Shared data directory for filesystem server
├── filesystem/
│   └── Dockerfile             # Filesystem server container (mcp-proxy)
├── sequential-thinking/
│   └── Dockerfile             # Sequential thinking server container (mcp-proxy)
├── git/
│   ├── Dockerfile             # Git server container (Python + Flask)
│   └── http_wrapper.py        # HTTP wrapper for stdio server
├── time/
│   ├── Dockerfile             # Time server container (Python + Flask)
│   └── http_wrapper.py        # HTTP wrapper for stdio server
├── fetch/
│   ├── Dockerfile             # Fetch server container (Python + Flask)
│   └── http_wrapper.py        # HTTP wrapper for stdio server
├── memory/
│   └── Dockerfile             # Memory server container (supergateway)
└── everything/
    └── Dockerfile             # Everything server container (supergateway)
```

## Installation Methods

- **npm packages + mcp-proxy**: `filesystem`, `sequential-thinking` (HTTP/SSE via mcp-proxy)
- **Python packages + Flask**: `git`, `time`, `fetch` (HTTP/SSE via custom wrapper)
- **GitHub source + supergateway**: `memory`, `everything` (currently failing - executable not found)

## Usage

### Start all servers
```bash
docker-compose up --build -d
```

### Start specific server
```bash
docker-compose up --build -d filesystem
```

### View logs
```bash
docker-compose logs -f
```

### Stop all servers
```bash
docker-compose down
```

## Ports and Endpoints

- **8801**: Filesystem server - `http://localhost:8801/sse`
- **8802**: Memory server - `http://localhost:8802/sse` (⚠️ not working)
- **8803**: Sequential thinking server - `http://localhost:8803/sse`
- **8804**: Git server - `http://localhost:8804/sse`
- **8805**: Time server - `http://localhost:8805/sse`
- **8806**: Fetch server - `http://localhost:8806/sse`
- **8807**: Everything server - `http://localhost:8807/sse` (⚠️ not working)

## Health Check Endpoints

All servers provide health check endpoints:
- Python servers: `http://localhost:PORT/health`
- Node.js servers: No health endpoint (use SSE endpoint instead)

## Benefits of This Approach

1. **Modularity**: Each server is isolated and can be updated independently
2. **Scalability**: Easy to scale individual services
3. **Debugging**: Isolated logs and easier troubleshooting
4. **Resource Management**: Better control over resource allocation per service
5. **Docker Best Practices**: Follows containerization best practices
6. **HTTP/SSE Support**: All servers expose HTTP/SSE endpoints for easy integration
7. **Mixed Technologies**: Supports both Node.js and Python-based MCP servers

## Current Status

✅ **Working Servers:**
- filesystem (Node.js + mcp-proxy)
- sequential-thinking (Node.js + mcp-proxy)
- git (Python + Flask wrapper)
- time (Python + Flask wrapper)
- fetch (Python + Flask wrapper)

⚠️ **Issues:**
- memory: Executable not found in supergateway container
- everything: Executable not found in supergateway container

## Next Steps

To fix the remaining servers:
1. Investigate why the GitHub-based servers aren't creating executables properly
2. Consider using mcp-proxy for all Node.js servers instead of supergateway
3. Add proper health endpoints to Node.js servers 