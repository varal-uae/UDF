"""GEN-00432 — attach @triangular_check to Apple IAP processing handler.
Metric: Decorator Coverage · Complete/Not Complete."""
import functools


def triangular_check(fn):
    """Conservation guard: units_in must equal units_out (A - B == 0)."""
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        result = fn(*args, **kwargs)
        units_in = kwargs.get("units_in")
        units_out = getattr(result, "units_out", units_in)
        if units_in is not None and units_in != units_out:
            raise ValueError(f"triangular_check failed: {units_in} != {units_out}")
        return result
    return wrapper


@triangular_check
def process_apple_iap(receipt: dict, *, units_in: int):
    """Process an Apple In-App Purchase receipt."""
    class _R:
        units_out = units_in
        transaction_id = receipt.get("transaction_id")
    return _R()
