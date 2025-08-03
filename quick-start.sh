#!/bin/bash

# Quick Start Script for MCP Servers
# Easy setup and testing for the MCP servers

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 MCP Servers Quick Start${NC}"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"
echo ""

# Start all servers
echo "📦 Starting all MCP servers..."
./mcp-manager.sh start

echo ""
echo "🔍 Testing server connectivity..."
./mcp-manager.sh test

echo ""
echo "📋 Current status:"
./mcp-manager.sh status

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "📝 Next steps:"
echo "1. Configure Cursor IDE with .modelcontextrc.json"
echo "2. Use './mcp-manager.sh investigate' to debug any issues"
echo "3. Use './mcp-manager.sh logs [service]' to view logs"
echo ""
echo "📚 Available commands:"
echo "  ./mcp-manager.sh start      # Start all servers"
echo "  ./mcp-manager.sh stop       # Stop all servers"
echo "  ./mcp-manager.sh status     # Check status"
echo "  ./mcp-manager.sh investigate # Debug issues"
echo "  ./mcp-manager.sh help       # Show all commands" 