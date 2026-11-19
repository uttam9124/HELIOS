from flask import Flask, jsonify
import os
import platform
from datetime import datetime, timezone

app = Flask(__name__)


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


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
