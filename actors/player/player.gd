class_name Player
extends Actor

"""
A local player-controlled character.
"""


enum State {
    LOADING,
    MOVING,
    EXITING_LEVEL,
    DEAD,
}

enum Trigger {
    LEVEL_EXITED,
    LEVEL_ENTERED,
    DIED,
}


@export var flash_times: int = 3


@onready var _visual: AnimatedSprite2D = $Visual


var _fsm: FiniteStateMachine = FiniteStateMachine.new(self)


func _ready() -> void:
    super._ready() # load abilities from actor

    EventBus.level_entered.connect(_on_level_entered)
    EventBus.level_exited.connect(_on_level_exited)
    EventBus.attack_failed.connect(_on_attack_failed)


    _fsm.setup(State.LOADING).bind($States/Loading) \
        .permit(Trigger.LEVEL_ENTERED, State.MOVING)

    _fsm.setup(State.MOVING).bind($States/Moving) \
        .on_enter(_enter_moving) \
        .on_exit(_exit_moving) \
        .permit(Trigger.LEVEL_EXITED, State.EXITING_LEVEL) \
        .permit(Trigger.DIED, State.DEAD)

    _fsm.setup(State.EXITING_LEVEL).bind($States/ExitingLevel) \
        .on_enter(_enter_exiting_level) \
        .on_exit(_exit_exiting_level) \
        .permit(Trigger.LEVEL_ENTERED, State.MOVING) \
        .permit(Trigger.DIED, State.DEAD)

    _fsm.setup(State.DEAD).bind($States/Dead) \
        .on_enter(_enter_death) \
        .final_state()

    _fsm.start(State.LOADING)


func _input(event: InputEvent) -> void:
    if event.is_action("change_direction") and event.is_pressed():
        activate_affector(Global.AFFECTOR.CHANGE_DIRECTION)


func _on_pickup_item_enter(item: PickupItem) -> void:
    print("player: pickup contact with item %s" % item.pickup_name)
    match item.kind:
        PickupData.Kind.KEY:

            activate_affector(Global.AFFECTOR.PICKUP_ITEM, { PickupAbility.PARAM_ITEM: item })
        _:
            push_warning("player: unhandled pickup item kind %s" % [str(item.kind)])


func _on_door_enter(door: Door) -> void:
    print("player: door contact with door %s" % door.name)
    if door.is_exit and not door.is_locked:
        activate_affector(Global.AFFECTOR.EXIT_LEVEL, { ExitLevelAbility.PARAM_EXIT_DOOR: door })


func _on_monster_enter(_monster: Actor) -> void:
    print("player: contacted by monster %s" % _monster.name)
    activate_affector(Global.AFFECTOR.ATTACK, { AttackAbility.PARAM_TARGET: _monster })


func _enter_moving() -> void:
    activate_affector(Global.AFFECTOR.MOVE)
    _visual.play(Global.ANIM_RUN)


func _exit_moving() -> void:
    deactivate_affector(Global.AFFECTOR.MOVE)
    _visual.stop()


func _enter_exiting_level() -> void:
    pass # To be implemented


func _exit_exiting_level() -> void:
    pass # To be implemented


func _on_level_entered(actor: Actor, _level: Level) -> void:
    if actor != self:
        return

    _fsm.send(Trigger.LEVEL_ENTERED)


func _on_level_exited(actor: Actor, _level: Level) -> void:
    if actor != self:
        return

    _fsm.send(Trigger.LEVEL_EXITED)


func _on_attack_failed(_winner: Actor, loser: Actor) -> void:
    if loser != self:
        return

    print("player: attack failed, changing direction")
    activate_affector(Global.AFFECTOR.CHANGE_DIRECTION)


func _on_hurt(amount: int) -> void:
    print("player: player hurt for %d damage" % amount)
    super._on_hurt(amount)
    var hurt: Affector = _affectors[Global.AFFECTOR.HURT]
    var cool_down: float = hurt.cool_down
    var interval: float = cool_down / (flash_times * 2)

    var mat: ShaderMaterial = _visual.material as ShaderMaterial
    var tween: Tween = create_tween()
    tween.set_loops(flash_times)
    tween.tween_callback(func(): mat.set_shader_parameter("active", true))
    tween.tween_interval(interval)
    tween.tween_callback(func(): mat.set_shader_parameter("active", false))
    tween.tween_interval(interval)


func _on_death() -> void:
    disable_all_affectors()
    _fsm.send(Trigger.DIED)


func _enter_death() -> void:
    print("player: player has died")
    _visual.play(Global.ANIM_DEATH)
    await _visual.animation_finished
    EventBus.actor_killed.emit(self)
