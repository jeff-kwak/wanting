class_name ActorData
extends Resource

"""
Defines various stats and attributes for actors in the game.
---
Stats represent inherent attributes of actors, such as speed,
strength, or intelligence. These stats can influence gameplay mechanics
and interactions.
"""


@export_category("Basic Info")
@export var actor_name: String = "Unnamed Actor"
@export var description: String = "No description available."


@export_category("Battle Stats")
@export var max_health: int = 1
@export var attack: int = 0
@export var defense: int = 0


@export_category("Movement")
@export var speed: float = 0.0


@export_category("Visual Appearance")
@export var sprite_frames: SpriteFrames
