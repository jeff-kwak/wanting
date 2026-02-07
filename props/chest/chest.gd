class_name Chest
extends Node2D


const LOOT_DROP_POSITION_OFFSET: Vector2 = Vector2(0, -8)


enum State {
    CLOSED,
    OPEN,
}


enum Trigger {
    OPEN,
    CLOSE,
}


@onready var _visual: AnimatedSprite2D = $Visual


var _pickup_scene: PackedScene = preload("res://items/pickup_item.tscn")
var _items: Array[PickupData] = [ ]
var _fsm: FiniteStateMachine = FiniteStateMachine.new(self)


func add_to_chest(item: PickupData) -> void:
    _items.append(item)


func _ready():
    _visual.play(Global.ANIM_CLOSED)

    _fsm.setup(State.CLOSED).bind($States/Closed) \
        .on_enter(_enter_closed) \
        .permit(Trigger.OPEN, State.OPEN)

    _fsm.setup(State.OPEN).bind($States/Open) \
        .on_enter(_enter_open) \
        .permit(Trigger.CLOSE, State.CLOSED)

    _fsm.start(State.CLOSED)


func _on_chest_box_area_entered(area: Area2D) -> void:
    if area.is_in_group(Global.GROUP_PLAYER):
        var player: Player = area.get_parent() as Player
        if player:
            _fsm.send(Trigger.OPEN)


func _enter_closed() -> void:
    _visual.play(Global.ANIM_CLOSED)


func _enter_open() -> void:
    _visual.play(Global.ANIM_OPEN)
    await _visual.animation_finished

    var level: Level = get_parent() as Level
    if not level:
        push_error("Chest is not a child of a Level node?!")
        return

    for treasure_data in _items:
        var treasure_instance: PickupItem = _pickup_scene.instantiate()
        treasure_instance.position = position + LOOT_DROP_POSITION_OFFSET
        treasure_instance.pickup_data = treasure_data
        treasure_instance.name = "%s_%d" % [treasure_data.pickup_name, level.level_number]
        level.add_child(treasure_instance)

    _items.clear()
