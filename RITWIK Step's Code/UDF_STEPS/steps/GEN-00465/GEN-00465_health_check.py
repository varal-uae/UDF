"""GEN-00465 — post-deployment health check pinging /health.
Metric: Liveness Response Rate · Pass/Fail."""
import sys
import urllib.request


def check(base_url: str, timeout: float = 5.0) -> bool:
    try:
        with urllib.request.urlopen(f"{base_url}/health", timeout=timeout) as r:
            return r.status == 200
    except Exception:
        return False


if __name__ == "__main__":
    ok = check(sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080")
    print("PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)
