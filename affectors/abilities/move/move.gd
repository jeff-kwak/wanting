class_name MoveAbility
extends Affector

"""
An affector that allows an actor to move to a specified position.
---
This affector enables an actor to change its position in the game world.
The affector will move speed in the direction of the actor.
"""


func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.MOVE


func _on_update(delta: float) -> void:
    if is_active:
        var direction: Vector2 = Vector2(actor.facing_direction, 0) # already normal
        actor.move_to(actor.global_position + direction * actor.data.speed * delta)

