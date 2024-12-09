#!/usr/bin/env python3
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler

# Retrieve configuration from environment variables
REPOS_DIR = os.getenv('REPOS_DIR', './repos')
REPOS_IPADDR = os.getenv('REPOS_IPADDR', 'localhost')
REPOS_PORT = int(os.getenv('REPOS_PORT', 8080))

# Change the working directory to the repository directory
if not os.path.exists(REPOS_DIR):
    print(f"Error: Repository directory '{REPOS_DIR}' does not exist.")
    exit(1)
os.chdir(REPOS_DIR)

# Define and start the HTTP server
class CustomHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        """Override to suppress unnecessary logging."""
        pass

def run_server():
    print(f"Starting HTTP server at http://{REPOS_IPADDR}:{REPOS_PORT}")
    httpd = HTTPServer((REPOS_IPADDR, REPOS_PORT), CustomHandler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down the server.")
        httpd.server_close()

if __name__ == "__main__":
    run_server()
