from fastapi.testclient import TestClient

import pytest

from hello_svc.views import app


@pytest.fixture(name="client")
def _client():
    return TestClient(app)


def test_hello(client):
    """
    Service greets the world.
    """
    resp = client.get("/")

    assert 200 == resp.status_code
    assert {"message": "Hello World"} == resp.json()
