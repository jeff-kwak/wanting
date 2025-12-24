class_name HurtStatusEffect
extends Affector

"""
A status effect that represents an actor being hurt.
Reduces the actor's health by a specified amount when applied.
"""


const PARAM_DAMAGE: StringName = "damage"


func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.HURT


func _on_activate(context := { }) -> bool:
    var damage: int = context[PARAM_DAMAGE]
    if not damage:
        push_error("hurt: applied without damage parameter")
        return false

    print("hurt: applying %d damage to actor %s" % [damage, actor.name])
    actor.apply_damage(damage)

    return true # apply cooldown
