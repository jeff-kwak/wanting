class_name Vermin
extends Actor

"""
Vermin monsters are simple monsters with 16x32 sprites.
They have basic AI and low health. They cannot pickup items.
They cannot move between levels. These are the lowest tier
monsters in the game.

Monster Tiers:
1. Vermin

"""


@onready var _visual: AnimatedSprite2D = $Visual


func _ready():
    super._ready() # load afffectors

    if not data:
        push_error("Vermin actor has no data assigned.")
        return

    print("vermin: loading '%s'" % data.actor_name)

    _visual.sprite_frames = data.sprite_frames

    _vermin_start.call_deferred()


func _on_player_enter(player: Actor) -> void:
    print("vermin: player entered vermin area, attacking")
    activate_affector(Global.AFFECTOR.ATTACK, { AttackAbility.PARAM_TARGET: player })


func _vermin_start() -> void:
    _visual.play(Global.ANIM_RUN)
    activate_affector(Global.AFFECTOR.MOVE)

    # randomly choose a direction
    if randi() % 2 == 0:
        activate_affector(Global.AFFECTOR.CHANGE_DIRECTION)
