"""GEN-00663 — Cloud Run sync worker exporting identity pairs to a feature store
(Redis / Cloud Bigtable). Metric: Sync Throughput · Pass/Fail.
The store client is injected so the worker is portable and testable."""
from typing import Protocol, Iterable, Tuple


class FeatureStore(Protocol):
    def put(self, key: str, value: str) -> None: ...


def sync_identity_pairs(pairs: Iterable[Tuple[str, str]], store: FeatureStore) -> int:
    n = 0
    for key, value in pairs:
        store.put(f"identity:{key}", value)
        n += 1
    return n
