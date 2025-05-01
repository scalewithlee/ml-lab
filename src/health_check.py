"""
health_check: basic flask app for health checks
"""
from flask import Flask, jsonify
import socket
import psutil
import logging

app = Flask(__name__)
logger = logging.getLogger(__name__)

@app.route('/health/liveness')
def liveness():
    """Basic health check to verify service is running"""
    return jsonify({"status": "all good, yo."})

@app.route('/health/readiness')
def readiness():
    """More detailed check to verify service can process requests"""
    health_info = {
        'status': 'ready',
        'hostname': socket.gethostname(),
        'cpu_percent': psutil.cpu_percent(),
        'memory_percent': psutil.virtual_memory().percent,
        'disk_percent': psutil.disk_usage('/').percent
    }
    return jsonify(health_info)

def run_health_server(port=8080):
    """Run the health check server"""
    logger.info(f"Health check server starting on port {port}")
    app.run(host='0.0.0.0', port=port)

if __name__ == '__main__':
    from logging_config import setup_logging
    setup_logging()
    run_health_server()
