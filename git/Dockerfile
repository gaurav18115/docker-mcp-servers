FROM python:3.12-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install the git server and HTTP dependencies
RUN pip install mcp-server-git flask flask-cors

# Copy the HTTP wrapper
COPY http_wrapper.py .

EXPOSE 8804

CMD ["python", "http_wrapper.py", "git", "8804"] 