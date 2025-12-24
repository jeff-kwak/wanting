class_name InvincibleStatusEffect
extends Affector

"""
A status effect that makes an actor invincible.
Prevents the actor from taking any damage while active.
---
The invincible status effect is checked by the actor's apply_damage method
"""

func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.INVINCIBLE


func _on_activate(_context := { }) -> bool:
    return true
