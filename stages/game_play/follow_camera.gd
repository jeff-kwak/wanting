class_name GamePlayFollowCamera
extends Camera2D

@export var follow_target: Node2D
@export var camera_speed: float = 0.3
@export var top_drag_margin: float = -80.0 # Negative is up
@export var bottom_drag_margin: float = 0.0


var _moving: bool = false


func _process(_delta: float) -> void:
    if not follow_target:
        return

    if not _moving and not is_equal_approx(global_position.y, follow_target.global_position.y):
        var distance =  follow_target.global_position.y - global_position.y

        # top-drag
        if distance < 0 and distance > top_drag_margin:
            return

        # bottom-drag
        if distance > 0 and distance < bottom_drag_margin:
            return

        _moving = true
        _move_to_target()


func _move_to_target() -> void:
    var tween: Tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "global_position:y", follow_target.global_position.y, camera_speed)
    await tween.finished
    _moving = false
