class_name HealthBar
extends HBoxContainer


@export var full_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D


var max_health: int = 3:
    get:
        return max_health
    set(value):
        max_health = value
        _update_hearts()


var current_health: int = 2:
    get:
        return current_health
    set(value):
        current_health = value
        _update_hearts()


func _ready() -> void:
    max_health = max_health
    current_health = current_health

    EventBus.actor_max_health_changed.connect(_on_actor_max_health_changed)
    EventBus.actor_current_health_changed.connect(_on_actor_current_health_changed)


func _update_hearts() -> void:
    if not full_heart_texture or not empty_heart_texture:
        return

    _erase_contents()
    for i in range(max_health):
        var heart: TextureRect = TextureRect.new()
        if i < current_health:
            heart.texture = full_heart_texture
        else:
            heart.texture = empty_heart_texture
        add_child(heart)


func _erase_contents() -> void:
    for child in get_children():
        child.queue_free()


func _on_actor_max_health_changed(actor: Actor, health: int) -> void:
    if actor is Player:
        max_health = health


func _on_actor_current_health_changed(actor: Actor, health: int) -> void:
    if actor is Player:
        current_health = health
