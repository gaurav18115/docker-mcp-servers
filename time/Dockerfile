FROM python:3.12-slim

# Install the time server and HTTP dependencies
RUN pip install mcp-server-time flask flask-cors

# Copy the HTTP wrapper
COPY http_wrapper.py .

EXPOSE 8805

CMD ["python", "http_wrapper.py", "time", "8805"] 