"""GEN-00818 — circuit breaker freezing table partitions when Cloud DLP detects
raw PII. Metric: PII Containment Response · Pass/Fail."""
from typing import Callable


def dlp_circuit_breaker(partition_id: str, dlp_findings: list[dict],
                        freeze: Callable[[str], None]) -> bool:
    """Freeze the partition if any DLP finding indicates raw PII. Returns frozen?"""
    has_pii = any(f.get("info_type") for f in dlp_findings)
    if has_pii:
        freeze(partition_id)
    return has_pii
