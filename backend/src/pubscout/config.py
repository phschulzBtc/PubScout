from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "PubScout"
    overpass_api_url: str = "https://overpass-api.de/api/interpreter"
    default_search_radius_km: float = 5.0

    model_config = {"env_file": ".env"}


settings = Settings()
