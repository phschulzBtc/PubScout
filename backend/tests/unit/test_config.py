from pubscout.config import Settings

# overpass-api.de blocks our IP after rate-limit violations; the openstreetmap.fr
# instance is the agreed default (reverted once by accident in a merge).
EXPECTED_OVERPASS_API_URL = "https://overpass.openstreetmap.fr/api/interpreter"


def test_default_overpass_api_url_is_openstreetmap_fr(monkeypatch):
    monkeypatch.delenv("OVERPASS_API_URL", raising=False)

    settings = Settings(_env_file=None)

    assert settings.overpass_api_url == EXPECTED_OVERPASS_API_URL
