"""Synthetic example module for the sandbox. No real functionality."""


def add(a, b):
    return a + b


def clamp(value, low, high):
    if low > high:
        raise ValueError("low must not be greater than high")
    return max(low, min(value, high))


def average(values):
    if not values:
        raise ValueError("values must not be empty")
    return sum(values) / len(values)
