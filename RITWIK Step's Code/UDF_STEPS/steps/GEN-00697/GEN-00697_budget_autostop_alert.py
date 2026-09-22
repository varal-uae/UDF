"""GEN-00697 — 100% budget-consumption auto-stop push alert payload.
Metric: Alert Trigger Accuracy · Pass/Fail."""


def build_autostop_payload(campaign_id: str, spent: float, budget: float) -> dict | None:
    """Return an alert payload only when budget is fully consumed."""
    if budget <= 0:
        raise ValueError("GEN-00697: budget must be positive")
    if spent < budget:
        return None
    return {
        "type": "BUDGET_AUTOSTOP",
        "campaign_id": campaign_id,
        "consumption_pct": round(spent / budget * 100, 2),
        "action": "PAUSE_CAMPAIGN",
    }
