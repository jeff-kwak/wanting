class_name Vermin
extends Actor
"""
Vermin monsters are simple monsters with 16x32 sprites.
They have basic AI and low health. They cannot pickup items.
They cannot move between levels. They have no battle animations.
They are the lowest tier of monsters.
"""

@export var death_time: float = 1.0
@export var death_flash_times: int = 5
@export var death_opacity: float = 0.8


@onready var _visual: VerminVisual = $Visual
@onready var _collision_area: Area2D = $Monster
@onready var _chance_timer: Timer = $ChanceTimer


var _is_stopped: bool = false


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


func _on_death() -> void:
    print("vermin: vermin %s has died" % name)
    # deactivate_affector(Global.AFFECTOR.MOVE)
    deactivate_all_affectors()
    disable_all_affectors()
    _chance_timer.stop()
    _visual.stop()
    _collision_area.set_deferred("monitorable", false)
    _collision_area.set_deferred("monitoring", false)

    _visual.modulate.a = death_opacity

    var interval: float = death_time / (death_flash_times * 2)
    var tween: Tween = create_tween()
    tween.set_loops(death_flash_times)
    tween.tween_callback(func(): _visual.visible = false)
    tween.tween_interval(interval)
    tween.tween_callback(func(): _visual.visible = true)
    tween.tween_interval(interval)

    await tween.finished

    EventBus.actor_killed.emit(self)


func _vermin_start() -> void:
    activate_affector(Global.AFFECTOR.MOVE)
    _visual.run()

    # randomly choose a direction
    if randi() % 2 == 0:
        activate_affector(Global.AFFECTOR.CHANGE_DIRECTION)

    if data.chance_timer > 0.0:
        _chance_timer.wait_time = data.chance_timer
        _chance_timer.start()



func _on_chance_timer_timeout() -> void:
    var roll_for_stop: float = randf()
    var roll_for_change_direction: float = randf()

    if roll_for_stop < data.chance_to_stop:
        if _is_stopped:
            activate_affector(Global.AFFECTOR.MOVE)
            _visual.run()
            _is_stopped = false
        else:
            deactivate_affector(Global.AFFECTOR.MOVE)
            _visual.idle()
            _is_stopped = true

    if roll_for_change_direction < data.chance_to_change_direction:
        activate_affector(Global.AFFECTOR.CHANGE_DIRECTION)
