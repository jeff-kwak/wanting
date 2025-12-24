class_name Affector
extends Node

"""
Base class for all affectors in the game.
---
Abilities define actions that actors can perform, such as attacking,
defending, or using items. Abilities can target other actors or apply effects.
Affectors can also define status effects that modify actor attributes over time,
such as poison or stun.
"""

var kind: Global.AFFECTOR:
    get:
        return _get_kind()


@export var cool_down: float = 0.0


var actor: Actor


var is_active: bool:
    get:
        return is_active
    set(value):
        is_active = value
        if actor: # will be Nil on load before ready when init value is set
            if is_active:
                EventBus.affector_activated.emit(actor, self)
            else:
                EventBus.affector_deactivated.emit(actor, self)


@export var is_enabled: bool = true


var _cooldown_timer: float = 0.0


func activate(context := { }) -> void:
    if can_activate():
        @warning_ignore("redundant_await") # some abilities are async
        is_active = await _on_activate(context)
        if is_active:
            _cooldown_timer = cool_down

        EventBus.affector_activated.emit(actor, self)


func deactivate() -> void:
    if is_active:
        is_active = _on_deactivate()
        EventBus.affector_deactivated.emit(actor, self)


func enable() -> void:
    is_enabled = true


func disable() -> void:
    is_enabled = false


func can_activate() -> bool:
    return not is_active and is_enabled


func _ready() -> void:
    actor = get_parent().get_parent() as Actor


func _process(delta: float) -> void:
    if _cooldown_timer > 0.0:
        _cooldown_timer -= delta
        EventBus.affector_cooldown_progress.emit(actor, self, _cooldown_timer, cool_down)
        if _cooldown_timer <= 0.0:
            _cooldown_timer = 0.0
            _on_cooldown_complete()
            EventBus.affector_cooldown_completed.emit(actor, self)
            is_active = false

    if is_active:
        _on_update(delta)


func _on_cooldown_complete() -> void:
    print("affector: cooldown complete for affector %s of actor %s" % [Global.AFFECTOR.keys()[kind], actor.name])
    pass # Override in subclasses if needed


### Override these methods in specific abilities ###
func _get_kind() -> Global.AFFECTOR:
    push_error("affector: _get_kind() not implemented for %s" % [self.get_class()])
    return Global.AFFECTOR.NONE


## Return true if the affector is activate after this method
func _on_activate(_context := { }) -> bool:
    return true


## Return false if the affector is no longer active
func _on_deactivate() -> bool:
    return false


func _on_update(_delta: float) -> void:
    pass
