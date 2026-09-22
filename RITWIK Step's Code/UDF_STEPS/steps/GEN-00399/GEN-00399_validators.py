"""GEN-00399 — validators.py: inspect inbound UTM structure.
Metric: Validator Execution Latency · Complete/Not Complete."""
import re

_UTM_KEYS = ("utm_source", "utm_medium", "utm_campaign")
_ALLOWED = re.compile(r"^[A-Za-z0-9_\-\.]{1,64}$")


def validate_utm(params: dict) -> tuple[bool, list[str]]:
    """Return (ok, errors). ok=True only if all required UTM keys are present
    and well-formed."""
    errors = []
    for k in _UTM_KEYS:
        v = params.get(k)
        if v is None:
            errors.append(f"missing {k}")
        elif not _ALLOWED.match(str(v)):
            errors.append(f"malformed {k}: {v!r}")
    return (len(errors) == 0, errors)
