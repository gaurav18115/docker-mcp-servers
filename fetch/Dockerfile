FROM python:3.12-slim

# Install the fetch server and HTTP dependencies
RUN pip install mcp-server-fetch flask flask-cors

# Copy the HTTP wrapper
COPY http_wrapper.py .

EXPOSE 8806

CMD ["python", "http_wrapper.py", "fetch", "8806"] 