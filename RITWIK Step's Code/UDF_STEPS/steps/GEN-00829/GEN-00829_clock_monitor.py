"""GEN-00829 — @clock_monitor decorator for backend microservice functions.
Metric: Function Instrumentation Coverage · Pass/Fail."""
import functools
import time
from typing import Callable

_METRICS: dict[str, float] = {}


def clock_monitor(fn: Callable) -> Callable:
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        try:
            return fn(*args, **kwargs)
        finally:
            _METRICS[fn.__qualname__] = (time.perf_counter() - start) * 1000.0
    return wrapper


def last_duration_ms(qualname: str) -> float | None:
    return _METRICS.get(qualname)
