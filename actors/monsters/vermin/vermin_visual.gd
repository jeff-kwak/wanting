class_name VerminVisual
extends AnimatedSprite2D



func run() -> void:
    play(Global.ANIM_RUN)


func idle() -> void:
    play(Global.ANIM_IDLE)


func _ready() -> void:
    play(Global.ANIM_IDLE)
