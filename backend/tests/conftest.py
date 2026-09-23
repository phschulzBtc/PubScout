import pytest
from fastapi.testclient import TestClient

from pubscout.main import app


@pytest.fixture
def client():
    return TestClient(app)
