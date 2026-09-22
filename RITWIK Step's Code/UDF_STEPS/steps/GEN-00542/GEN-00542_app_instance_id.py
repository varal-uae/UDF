"""GEN-00542 — Extract app_instance_id from the Firebase SDK (mobile client).
Metric: Identifier Extraction Success · Pass/Fail.
(Client boundary helper; the SDK call is injected so this stays testable.)"""
from typing import Callable, Optional


def extract_app_instance_id(sdk_get_id: Callable[[], Optional[str]]) -> str:
    app_id = sdk_get_id()
    if not app_id:
        raise RuntimeError("GEN-00542: Firebase app_instance_id unavailable")
    return app_id
