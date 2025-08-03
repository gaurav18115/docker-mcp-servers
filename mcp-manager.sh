#!/bin/bash

# MCP Servers Manager Script
# Manages Docker-based MCP servers with comprehensive control and monitoring

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Server configurations
SERVERS=(
    "filesystem:8801:Node.js + mcp-proxy"
    "sequential-thinking:8803:Node.js + mcp-proxy"
    "git:8804:Python + Flask"
    "time:8805:Python + Flask"
    "fetch:8806:Python + Flask"
    "memory:8802:Node.js + mcp-proxy"
    "everything:8807:Node.js + mcp-proxy"
)

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success") echo -e "${GREEN}✅ $message${NC}" ;;
        "error") echo -e "${RED}❌ $message${NC}" ;;
        "warning") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "info") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_status "error" "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to start all servers
start_all() {
    print_status "info" "Starting all MCP servers..."
    check_docker
    
    docker-compose up --build -d
    
    if [ $? -eq 0 ]; then
        print_status "success" "All servers started successfully!"
        echo ""
        print_status "info" "Waiting 10 seconds for servers to initialize..."
        sleep 10
        status_all
    else
        print_status "error" "Failed to start servers"
        exit 1
    fi
}

# Function to stop all servers
stop_all() {
    print_status "info" "Stopping all MCP servers..."
    check_docker
    
    docker-compose down
    
    if [ $? -eq 0 ]; then
        print_status "success" "All servers stopped successfully!"
    else
        print_status "error" "Failed to stop servers"
        exit 1
    fi
}

# Function to restart all servers
restart_all() {
    print_status "info" "Restarting all MCP servers..."
    stop_all
    sleep 2
    start_all
}

# Function to show status of all servers
status_all() {
    print_status "info" "Checking status of all MCP servers..."
    echo ""
    
    # Get container status
    local containers=$(docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep mcp-servers)
    
    if [ -z "$containers" ]; then
        print_status "warning" "No MCP server containers found"
        return
    fi
    
    echo -e "${BLUE}Container Status:${NC}"
    echo "$containers" | while IFS= read -r line; do
        if echo "$line" | grep -q "Up"; then
            echo -e "${GREEN}$line${NC}"
        elif echo "$line" | grep -q "Exited"; then
            echo -e "${RED}$line${NC}"
        else
            echo -e "${YELLOW}$line${NC}"
        fi
    done
    
    echo ""
    print_status "info" "Testing server connectivity..."
    test_connectivity
}

# Function to test server connectivity
test_connectivity() {
    local working=0
    local total=0
    
    for server_info in "${SERVERS[@]}"; do
        IFS=':' read -r name port description <<< "$server_info"
        total=$((total + 1))
        
        # Test health endpoint (for Python servers)
        if [[ "$description" == *"Python"* ]]; then
            if curl -s "http://localhost:$port/health" >/dev/null 2>&1; then
                print_status "success" "$name (port $port): Health endpoint working"
                working=$((working + 1))
                continue
            fi
        fi
        
        # Test SSE endpoint
        if curl -s "http://localhost:$port/sse" >/dev/null 2>&1; then
            print_status "success" "$name (port $port): SSE endpoint working"
            working=$((working + 1))
        else
            print_status "error" "$name (port $port): Not responding"
        fi
    done
    
    echo ""
    print_status "info" "Summary: $working/$total servers working"
    
    if [ $working -eq $total ]; then
        print_status "success" "All servers are running and accessible!"
    else
        print_status "warning" "Some servers are not working. Use 'investigate' command for details."
    fi
}

# Function to investigate failed servers
investigate() {
    print_status "info" "Investigating failed servers..."
    echo ""
    
    # Check which containers are not running
    local failed_containers=$(docker ps -a --format "{{.Names}}\t{{.Status}}" | grep mcp-servers | grep -v "Up")
    
    if [ -z "$failed_containers" ]; then
        print_status "success" "All containers are running!"
        return
    fi
    
    echo -e "${RED}Failed Containers:${NC}"
    echo "$failed_containers"
    echo ""
    
    # Show logs for failed containers
    echo "$failed_containers" | while IFS= read -r line; do
        local container_name=$(echo "$line" | awk '{print $1}')
        print_status "info" "Logs for $container_name:"
        docker logs "$container_name" --tail 20
        echo ""
    done
    
    # Check for common issues
    print_status "info" "Checking for common issues..."
    
    # Check if executables exist in containers
    for server_info in "${SERVERS[@]}"; do
        IFS=':' read -r name port description <<< "$server_info"
        
        if [[ "$description" == *"supergateway"* ]]; then
            local container_name="mcp-servers-$name-1"
            if docker ps -q -f name="$container_name" | grep -q .; then
                print_status "info" "Checking $name container for executable..."
                if ! docker exec "$container_name" which "mcp-server-$name" >/dev/null 2>&1; then
                    print_status "error" "$name: Executable 'mcp-server-$name' not found in container"
                    print_status "info" "This is likely due to the GitHub-based installation not working properly"
                fi
            fi
        fi
    done
}

# Function to show logs
show_logs() {
    local service_name=$1
    
    if [ -z "$service_name" ]; then
        print_status "info" "Showing logs for all services..."
        docker-compose logs -f
    else
        print_status "info" "Showing logs for $service_name..."
        docker-compose logs -f "$service_name"
    fi
}

# Function to rebuild specific server
rebuild_server() {
    local service_name=$1
    
    if [ -z "$service_name" ]; then
        print_status "error" "Please specify a service name to rebuild"
        echo "Available services: filesystem, sequential-thinking, git, time, fetch, memory, everything"
        exit 1
    fi
    
    print_status "info" "Rebuilding $service_name..."
    docker-compose build --no-cache "$service_name"
    docker-compose up -d "$service_name"
    print_status "success" "$service_name rebuilt and restarted"
}

# Function to show help
show_help() {
    echo "MCP Servers Manager Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start           Start all MCP servers"
    echo "  stop            Stop all MCP servers"
    echo "  restart         Restart all MCP servers"
    echo "  status          Show status of all servers"
    echo "  test            Test connectivity of all servers"
    echo "  investigate     Investigate failed servers"
    echo "  logs [SERVICE]  Show logs (all services or specific service)"
    echo "  rebuild SERVICE Rebuild and restart specific service"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all servers"
    echo "  $0 status                   # Check status"
    echo "  $0 investigate              # Investigate failures"
    echo "  $0 logs memory              # Show memory server logs"
    echo "  $0 rebuild memory           # Rebuild memory server"
    echo ""
    echo "Available services: filesystem, sequential-thinking, git, time, fetch, memory, everything"
}

# Main script logic
case "${1:-help}" in
    "start")
        start_all
        ;;
    "stop")
        stop_all
        ;;
    "restart")
        restart_all
        ;;
    "status")
        status_all
        ;;
    "test")
        test_connectivity
        ;;
    "investigate")
        investigate
        ;;
    "logs")
        show_logs "$2"
        ;;
    "rebuild")
        rebuild_server "$2"
        ;;
    "help"|*)
        show_help
        ;;
esac 