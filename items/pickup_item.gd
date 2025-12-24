@tool
class_name PickupItem
extends Node2D


const META_DOOR = "door"


@export var pickup_data: PickupData:
    get:
        return pickup_data
    set(value):
        pickup_data = value

        if _visual:
            _visual.texture = pickup_data.visual_texture


@export var animation_amplitude: float = 4.0
@export var animation_period: float = 1.0
@export var cool_down: float = 0.5


var can_be_picked_up: bool = true


var kind : PickupData.Kind:
    get:
        if pickup_data:
            return pickup_data.kind
        else:
            return PickupData.Kind.NONE


var pickup_name: String:
    get:
        if pickup_data:
            return pickup_data.pickup_name
        else:
            return "Unknown Item"


var metadata: Dictionary = { }


@onready var _visual: Sprite2D = $Visual


var _cooldown_timer: float = 0.0


func start_pickup_cooldown() -> void:
    can_be_picked_up = false
    _cooldown_timer = cool_down


func _ready() -> void:
    pickup_data = pickup_data
    _animate_vertical_movement()



func _process(delta: float) -> void:
    if _cooldown_timer > 0.0:
        _cooldown_timer = max(_cooldown_timer - delta, 0.0)
        if _cooldown_timer == 0.0:
            can_be_picked_up = true


func _animate_vertical_movement():
    await get_tree().create_timer(randf() * 0.5).timeout
    var start_y = position.y
    var tween = create_tween()
    tween.set_loops()  # Loop infinitely
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "position:y", start_y - animation_amplitude, animation_period * 0.5)
    tween.tween_property(self, "position:y", start_y + animation_amplitude, animation_period * 0.5)