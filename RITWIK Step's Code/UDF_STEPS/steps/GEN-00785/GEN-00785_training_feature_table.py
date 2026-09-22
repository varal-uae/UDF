"""GEN-00785 — construct training feature tables (early behaviour + channel + device).
Metric: Feature Completeness · Complete/Partial/Not Complete."""


def build_feature_row(early_events: dict, acquisition_channel: str, device: dict) -> dict:
    return {
        "events_0_24h": early_events.get("count_24h", 0),
        "sessions_0_24h": early_events.get("sessions_24h", 0),
        "acquisition_channel": acquisition_channel,
        "device_os": device.get("os"),
        "device_model": device.get("model"),
    }
