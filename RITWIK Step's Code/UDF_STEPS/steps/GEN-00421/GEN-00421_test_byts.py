"""GEN-00421 — pytest unit tests for each atomic Byt.
Metric: Unit Test Case Coverage · Complete/Not Complete."""
from attribution_byts import AttributionByt, register, REGISTRY


def test_register_returns_key():
    b = AttributionByt("b1", "google", {"utm_source": "google"})
    assert register(b) == "google:b1"


def test_registry_holds_byt():
    b = AttributionByt("b2", "meta", {})
    register(b)
    assert REGISTRY["meta:b2"] is b


def test_key_format():
    assert AttributionByt("x", "s", {}).key() == "s:x"
