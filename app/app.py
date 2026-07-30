from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)

# Prometheus metrics
request_count = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
request_latency = Histogram('http_request_duration_seconds', 'HTTP request latency')

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/todo', methods=['GET'])
def get_todos():
    request_count.labels(method='GET', endpoint='/api/todo').inc()
    return jsonify([])

@app.route('/api/todo', methods=['POST'])
def create_todo():
    request_count.labels(method='POST', endpoint='/api/todo').inc()
    return jsonify({'id': 1, 'title': 'Sample Todo'}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
