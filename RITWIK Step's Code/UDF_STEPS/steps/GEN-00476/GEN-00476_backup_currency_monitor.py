"""GEN-00476 — backup_currency_monitor.py.
Metric: Script Execution Time · Complete/Not Complete."""
import datetime as _dt


def check_backup_currency(last_backup_iso: str, max_age_hours: int = 24) -> bool:
    """True if the most recent backup is within max_age_hours."""
    last = _dt.datetime.fromisoformat(last_backup_iso)
    age = _dt.datetime.now(_dt.timezone.utc) - last
    return age <= _dt.timedelta(hours=max_age_hours)
