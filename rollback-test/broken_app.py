from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify({
        "project": "HELIOS",
        "version": "broken",
        "status": "running"
    })


@app.route("/health")
def health():
    return jsonify({
        "service": "helios",
        "status": "unhealthy",
        "reason": "Intentional deployment failure for rollback testing"
    }), 503


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
