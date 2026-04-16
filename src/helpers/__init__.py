"""Helper utilities for NexaMart data processing."""


def format_currency(value: float) -> str:
    """Format value as CAD currency."""
    return f"${value:,.2f}"


def safe_divide(numerator: float, denominator: float, default: float = 0.0) -> float:
    """Safe division that returns default on zero denominator."""
    if denominator == 0:
        return default
    return numerator / denominator
