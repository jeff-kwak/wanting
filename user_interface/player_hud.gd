class_name PlayerHud
extends Control


@export var player: Player:
    get:
        return player
    set(value):
        player = value
        _update_hud()


func _update_hud() -> void:
    if not player:
        push_error("PlayerHud: No player assigned.")
        return

    %ActorStats.actor = player
