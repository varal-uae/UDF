"""GEN-00741 — automated clawback report generation on fraud spikes.
Metric: Report Generation Latency · Complete/Not Complete."""


def generate_clawback_report(network: str, installs: list[dict], fraud_threshold: float = 0.10) -> dict:
    total = len(installs)
    fraudulent = [i for i in installs if i.get("fraud_score", 0) >= fraud_threshold]
    return {
        "ad_network": network,
        "total_installs": total,
        "clawback_count": len(fraudulent),
        "clawback_ids": [i["install_id"] for i in fraudulent if "install_id" in i],
        "clawback_rate": round(len(fraudulent) / total, 4) if total else 0.0,
    }
