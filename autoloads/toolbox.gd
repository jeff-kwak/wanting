extends Node

"""
General functions to be used across the game.
"""


func pick_weighted_index(weights: Array[float]) -> int:
    var total_weight: float = 0.0
    for weight in weights:
        total_weight += weight

    var random_value: float = randf() * total_weight
    var cumulative_weight: float = 0.0

    for i in range(len(weights)):
        cumulative_weight += weights[i]
        if random_value < cumulative_weight:
            return i

    return len(weights) - 1  # Fallback in case of rounding errors
