#!/usr/bin/env python3
import sys
import subprocess
import json
from flask import Flask, Response, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

server_type = sys.argv[1]
port = int(sys.argv[2])

@app.route('/sse')
def sse():
    def generate():
        # Start the MCP server process
        cmd = [f'mcp-server-{server_type}']
        if server_type == 'git' and len(sys.argv) > 3:
            cmd.extend(['-r', sys.argv[3]])
        
        process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        try:
            while True:
                # Read from stdout
                output = process.stdout.readline()
                if output:
                    yield f"data: {json.dumps({'type': 'output', 'data': output.strip()})}\n\n"
                
                # Check if process is still running
                if process.poll() is not None:
                    break
                    
        except Exception as e:
            yield f"data: {json.dumps({'type': 'error', 'data': str(e)})}\n\n"
        finally:
            process.terminate()
    
    return Response(generate(), mimetype='text/event-stream')

@app.route('/health')
def health():
    return json.dumps({'status': 'ok', 'server': server_type, 'port': port})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port) 