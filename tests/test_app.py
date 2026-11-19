import pytest
from app.app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True

    with app.test_client() as client:
        yield client


def test_home_endpoint(client):
    response = client.get("/")

    assert response.status_code == 200

    data = response.get_json()

    assert data["project"] == "HELIOS"
    assert data["status"] == "running"
    assert data["version"] == "1.0.0"


def test_health_endpoint(client):
    response = client.get("/health")

    assert response.status_code == 200

    data = response.get_json()

    assert data["status"] == "healthy"
    assert data["service"] == "helios"
    assert "timestamp" in data


def test_status_endpoint(client):
    response = client.get("/status")

    assert response.status_code == 200

    data = response.get_json()

    assert data["application"] == "HELIOS"
    assert data["status"] == "operational"
    assert data["environment"] == "development"


def test_system_endpoint(client):
    response = client.get("/system")

    assert response.status_code == 200

    data = response.get_json()

    assert "hostname" in data
    assert "operating_system" in data
    assert "os_release" in data
    assert "python_version" in data
