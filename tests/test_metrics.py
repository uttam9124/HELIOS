
from app.app import app


def test_metrics_endpoint():
    with app.test_client() as client:
        response = client.get("/metrics")

        assert response.status_code == 200
        assert "text/plain" in response.content_type


def test_http_request_counter():
    with app.test_client() as client:
        client.get("/")
        client.get("/health")

        response = client.get("/metrics")
        metrics = response.get_data(as_text=True)

        assert "helios_http_requests_total" in metrics
        assert 'endpoint="/health"' in metrics
        assert 'status="200"' in metrics


def test_http_request_duration():
    with app.test_client() as client:
        client.get("/")

        response = client.get("/metrics")
        metrics = response.get_data(as_text=True)

        assert "helios_http_request_duration_seconds_bucket" in metrics
        assert "helios_http_request_duration_seconds_count" in metrics
        assert "helios_http_request_duration_seconds_sum" in metrics
