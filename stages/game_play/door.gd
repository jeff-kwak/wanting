class_name Door
extends Node2D


@export var is_exit: bool = false:
    get:
        return is_exit
    set(value):
        is_exit = value
        if _key_icon:
            _key_icon.visible = is_exit


@export var unlock_delay: float = 0.0
@export var lock_delay: float = 0.5


@export var linked_door: Door
@export var key: PickupItem:
    get:
        return key
    set(value):
        if value and value.kind == PickupData.Kind.KEY:
            key = value
        if _key_icon and key:
            _key_icon.visible = key != null
            _key_icon.texture = key.pickup_data.visual_texture


var is_locked: bool:
    get:
        return _is_locked


var in_door_position: Vector2:
    get:
        return _in_door_position.global_position

var threshold_position: Vector2:
    get:
        return _threshold_position.global_position


@onready var _in_door_position: Marker2D = $InDoorPosition
@onready var _threshold_position: Marker2D = $ThresholdPosition
@onready var _door_animation: AnimatedSprite2D = $Visual
@onready var _key_icon: Sprite2D = $KeyIcon


var _is_locked: bool = true


func lock() -> void:
    if lock_delay > 0.0:
        var lock_timer: SceneTreeTimer = get_tree().create_timer(lock_delay)
        await lock_timer.timeout

    _lock_immediate()
    EventBus.door_locked.emit(self)


func unlock() -> void:
    if unlock_delay > 0.0:
        var unlock_timer: SceneTreeTimer = get_tree().create_timer(unlock_delay)
        await unlock_timer.timeout

    _unlock_immediate()
    EventBus.door_unlocked.emit(self)


func _ready() -> void:
    is_exit = is_exit
    _lock_immediate()


func _lock_immediate() -> void:
    _is_locked = true
    _door_animation.frame = 0


func _unlock_immediate() -> void:
    _is_locked = false
    _door_animation.frame = 1