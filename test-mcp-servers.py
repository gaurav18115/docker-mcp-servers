#!/usr/bin/env python3
"""
Test script to verify MCP servers are running and accessible
"""
import requests
import json
import sys

def test_server(port, name):
    """Test if an MCP server is responding"""
    try:
        # Test health endpoint (for Python servers)
        health_url = f"http://localhost:{port}/health"
        response = requests.get(health_url, timeout=5)
        if response.status_code == 200:
            print(f"✅ {name} (port {port}): Health endpoint working")
            return True
    except:
        pass
    
    try:
        # Test SSE endpoint
        sse_url = f"http://localhost:{port}/sse"
        response = requests.get(sse_url, timeout=5)
        if response.status_code == 200:
            print(f"✅ {name} (port {port}): SSE endpoint working")
            return True
    except:
        pass
    
    print(f"❌ {name} (port {port}): Not responding")
    return False

def main():
    """Test all MCP servers"""
    servers = [
        (8801, "filesystem"),
        (8802, "memory"),
        (8803, "sequential-thinking"),
        (8804, "git"),
        (8805, "time"),
        (8806, "fetch"),
        (8807, "everything")
    ]
    
    print("🔍 Testing MCP Servers...")
    print("=" * 40)
    
    working = 0
    total = len(servers)
    
    for port, name in servers:
        if test_server(port, name):
            working += 1
    
    print("=" * 40)
    print(f"📊 Results: {working}/{total} servers working")
    
    if working == total:
        print("🎉 All servers are running! Cursor should be able to connect.")
    else:
        print("⚠️  Some servers are not responding. Check docker-compose logs.")

if __name__ == "__main__":
    main() 