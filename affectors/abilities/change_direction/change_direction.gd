class_name ChangeDirectionAbility
extends Affector

"""
An affector that allows an actor to change its facing direction.
"""

func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.CHANGE_DIRECTION


func _on_activate(_context := { }) -> bool:
    actor.change_direction()
    return false # instant affector, no need to keep updating
