"""GEN-00443 — base pre_execute() class method.
Metric: Method Overhead Latency · Pass/Fail."""
from abc import ABC, abstractmethod


class AtomicStep(ABC):
    """Base for atomic steps. pre_execute runs guards before the main body."""

    def pre_execute(self, context: dict) -> None:
        """Validate context is present and non-empty before execution."""
        if not context:
            raise ValueError("pre_execute: empty execution context")

    @abstractmethod
    def execute(self, context: dict): ...
