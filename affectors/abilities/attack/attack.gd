class_name AttackAbility
extends Affector

"""
An affector that allows an actor to perform an attack.
---
Target another actor and apply a status effect of hurt to them.
"""

const PARAM_TARGET: StringName = "target"

const DAMAGE: int = 1


func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.ATTACK


func _on_activate(context := { }) -> bool:

    var target: Actor = context[PARAM_TARGET]
    if not target:
        push_error("attack: affector activated without target")
        return false

    var attack: int = actor.data.attack
    var defense: int = target.data.defense

    if attack > defense:
        # Currently just apply DAMAGE fixed damage
        target.activate_affector(Global.AFFECTOR.HURT, { HurtStatusEffect.PARAM_DAMAGE: DAMAGE })
        EventBus.attack_succeded.emit(actor, target)
    else:
        EventBus.attack_failed.emit(target, actor)

    return false # instant affector, not active after activation

