#!/usr/bin/env python3
"""Local stand-in for the external HTTP services the activity template tests
would otherwise hit (GitHub GraphQL and api.ipify.org), so CI does not depend on
flaky third-party network.

- POST (any path): a GitHub GraphQL `releases` response for the graphql-async
  template test.
- GET  (any path): an ipify-style JSON body for the http-simple-async test.

Usage: mock-http-server.py <port>
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

GRAPHQL_RELEASES = {
    "data": {
        "repository": {
            "releases": {
                "nodes": [
                    {"isLatest": True, "name": "Mock Release", "tagName": "v0.0.0"}
                ]
            }
        }
    }
}
IPIFY_JSON = {"ip": "127.0.0.1"}


class Handler(BaseHTTPRequestHandler):
    def _respond(self, payload):
        body = json.dumps(payload).encode()
        self.send_response(200)
        self.send_header("content-type", "application/json")
        self.send_header("content-length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        length = int(self.headers.get("content-length", 0))
        if length:
            self.rfile.read(length)
        self._respond(GRAPHQL_RELEASES)

    def do_GET(self):
        self._respond(IPIFY_JSON)

    def log_message(self, *_):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 18090
    server = HTTPServer(("127.0.0.1", port), Handler)
    print(f"mock http server on http://127.0.0.1:{port}", file=sys.stderr)
    server.serve_forever()
