
from flask import Flask, jsonify, request, g
from prometheus_client import (
    Counter,
    Histogram,
    generate_latest,
    CONTENT_TYPE_LATEST
)
import os
import platform
import time
from datetime import datetime, timezone

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    "helios_http_requests_total",
    "Total HTTP requests received by HELIOS",
    ["method", "endpoint", "status"]
)

REQUEST_DURATION = Histogram(
    "helios_http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "endpoint"]
)


@app.before_request
def start_timer():
    g.start_time = time.perf_counter()


@app.after_request
def record_metrics(response):
    if request.path != "/metrics":
        endpoint = request.url_rule.rule if request.url_rule else "unknown"

        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=endpoint,
            status=str(response.status_code)
        ).inc()

        REQUEST_DURATION.labels(
            method=request.method,
            endpoint=endpoint
        ).observe(time.perf_counter() - g.start_time)

    return response


@app.route("/")
def home():
    return jsonify({
        "project": "HELIOS",
        "description": "Automated Cloud Deployment Platform",
        "status": "running",
        "version": "1.0.0"
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "helios",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 200


@app.route("/status")
def status():
    return jsonify({
        "application": "HELIOS",
        "status": "operational",
        "environment": os.getenv("APP_ENV", "development"),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 200


@app.route("/system")
def system_info():
    return jsonify({
        "hostname": platform.node(),
        "operating_system": platform.system(),
        "os_release": platform.release(),
        "python_version": platform.python_version()
    }), 200


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {
        "Content-Type": CONTENT_TYPE_LATEST
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
