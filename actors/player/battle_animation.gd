class_name BattleAnimation
extends AnimationPlayer
"""
Handles battle animations for the player character.
---
I like having a class here to hide the strings
"""

signal finished(animation_name: String)


func _ready() -> void:
    animation_finished.connect(_on_animation_finished)


func attack(weapon: PickupItem) -> void:
    var anim: String = weapon.pickup_data.attack_animation
    match anim:
        Global.ANIM_SHORT_ATTACK:
            play(Global.ANIM_SHORT_ATTACK)
        _:
            push_error("battle_animation: unknown attack animation %s" % anim)
            _on_animation_finished(anim)


func _on_animation_finished(anim_name: String) -> void:
    finished.emit(anim_name)
