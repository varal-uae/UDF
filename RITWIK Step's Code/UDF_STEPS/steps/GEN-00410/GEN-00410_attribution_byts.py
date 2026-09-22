"""GEN-00410 — attribution_byts.py (master_library/byts/).
Metric: Module Registration Status · Complete/Not Complete."""
from dataclasses import dataclass


@dataclass(frozen=True)
class AttributionByt:
    """One atomic attribution unit (a 'Byt')."""
    byt_id: str
    source: str
    normalized_params: dict

    def key(self) -> str:
        return f"{self.source}:{self.byt_id}"


REGISTRY: dict[str, AttributionByt] = {}


def register(byt: AttributionByt) -> str:
    """Register a Byt in the module registry; returns its key."""
    REGISTRY[byt.key()] = byt
    return byt.key()
