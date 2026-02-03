class_name GamePlay
extends Node2D


enum State {
    LOADING,
    PLAYING,
    GAME_OVER,
    RESTARTING
}


enum Trigger {
    READY,
    PLAYER_DIED,
    TRY_AGAIN,
    QUIT_TO_MENU,
}


const INITIAL_LEVELS_TO_SPAWN: int = 16
const LEVELS_TO_BUFFER: int = 32
const MIN_LEVELS_AHEAD: int = 16
const MONSTER_SPAWN_Y_DISTANCE: int = 12


@export_category("Scenes")
@export var level_scene: PackedScene
@export var door_scene: PackedScene
@export var vermin_scene: PackedScene
@export var player_scene: PackedScene


@export_category("Level Generation")
@export var level_data: Array[LevelData]
@export var min_spawn_y_distance: int = 64


@onready var _level_container: Node2D = $Levels
@onready var _side_wall: SideWalls = $SideWalls
@onready var _game_over_dialog: GameOverDialog = %GameOverDialog
@onready var _player_hud: PlayerHud = %PlayerHud
@onready var _monster_hud: MonsterHud = %MonsterHud


var _level_buffer : Array[Level] = []
var _last_level_index : int = -1
var _pickup_scene: PackedScene = preload("res://items/pickup_item.tscn")
var _key_data: PickupData = preload("res://items/keys/golden_key.tres")
var _player: Player
var _player_level: int = 0


var _fsm: FiniteStateMachine = FiniteStateMachine.new(self)


func _ready() -> void:
    EventBus.level_entered.connect(_on_level_entered)
    EventBus.actor_killed.connect(_on_actor_killed)
    EventBus.item_picked_up.connect(_on_item_picked_up)
    EventBus.item_dropped.connect(_on_item_dropped)
    EventBus.affector_activated.connect(_on_affector_activated)
    EventBus.affector_cooldown_completed.connect(_on_affector_cooldown_completed)

    _fsm.setup(State.LOADING).bind($States/Loading) \
        .on_enter(_enter_loading) \
        .permit(Trigger.READY, State.PLAYING)

    _fsm.setup(State.PLAYING).bind($States/Playing) \
        .permit(Trigger.PLAYER_DIED, State.GAME_OVER)

    _fsm.setup(State.GAME_OVER).bind($States/GameOver) \
        .on_enter(_enter_game_over) \
        .on_exit(_exit_game_over) \
        .permit(Trigger.TRY_AGAIN, State.RESTARTING) \
        .permit(Trigger.QUIT_TO_MENU, State.GAME_OVER) \
        .on_trigger(Trigger.QUIT_TO_MENU, _quit_to_menu)

    _fsm.setup(State.RESTARTING).bind($States/Restarting) \
        .on_enter(_enter_restarting) \
        .on_exit(_exit_restarting) \
        .permit(Trigger.READY, State.PLAYING)

    _fsm.start(State.LOADING)


func _enter_loading() -> void:
    _level_buffer.clear()
    _level_buffer.resize(LEVELS_TO_BUFFER)
    _level_buffer.fill(null)
    _spawn_initial_levels()

    # TODO: there will have to be a start scene
    _spawn_player(_player_level)

    _fsm.send(Trigger.READY)


func _enter_restarting() -> void:
    print("game_play: restarting game")

    # have to make sure not allow the player to go
    # up levels past the start of the buffer
    var up_one: int = _player_level - 1
    var oldest: int = _last_level_index - LEVELS_TO_BUFFER + 1
    var target_level: int = up_one if up_one >= oldest else _player_level

    _spawn_player(target_level)
    _fsm.send(Trigger.READY)


func _exit_restarting() -> void:
    pass


func _quit_to_menu() -> void:
    EventBus.start_menu_requested.emit()


func _spawn_initial_levels() -> void:
    for i in range(INITIAL_LEVELS_TO_SPAWN):
        if _last_level_index < 0: # first level
            _spawn_level(Vector2.ZERO, level_data[0]) # TODO: lookup table
        else:
            _spawn_next_level()


func _spawn_next_level() -> void:
    var last_level: Level = _level_buffer[_last_level_index % LEVELS_TO_BUFFER]
    var new_pos: Vector2 = last_level.position + Vector2(0, min_spawn_y_distance)
    _spawn_level(new_pos, level_data[0]) # TODO: lookup table
    _spawn_doors()
    _spawn_monsters(level_data[0]) # TODO: lookup table based on depth
    _spawn_weapons(level_data[0]) # TODO: lookup table based on depth
    _spawn_shields(level_data[0]) # TODO: lookup table based on depth


func _spawn_level(pos: Vector2, data: LevelData) -> void:
    _last_level_index += 1
    print("game_play: spawn new level %s" % (_last_level_index + 1))
    var level_instance: Level = level_scene.instantiate()
    level_instance.position = pos
    level_instance.level_number = _last_level_index
    level_instance.level_data = data
    level_instance.name = "Level_%d" % (_last_level_index + 1)
    _level_container.add_child(level_instance)

    if _level_buffer[_last_level_index % LEVELS_TO_BUFFER] != null:
        print("game_play: remove level %s" % (_last_level_index + 1))
        _level_buffer[_last_level_index % LEVELS_TO_BUFFER].queue_free()

    _level_buffer[_last_level_index % LEVELS_TO_BUFFER] = level_instance
    _side_wall.spawn_walls_to_position(pos.y)


func _spawn_doors() -> void:
    if _last_level_index <= 0:
        return

    var previous: int = _last_level_index - 1
    var current: int = _last_level_index
    var previous_level: Level = _level_buffer[previous % LEVELS_TO_BUFFER]
    var current_level: Level = _level_buffer[current % LEVELS_TO_BUFFER]

    print("game_play: spawn exit door on level %d, pos %s" % [previous + 1, previous_level.position])
    var exit_door: Door = door_scene.instantiate()
    var door_position: int = _door_position(previous_level)
    previous_level.contents[door_position] = Level.Content.DOOR
    exit_door.position = Vector2((-Global.TILE_SIZE * previous_level.level_width_half) + (door_position * Global.TILE_SIZE),0)
    exit_door.is_exit = true
    exit_door.name = "Out_%d" % (previous + 1)
    previous_level.add_child(exit_door)

    # spawn a key for the exit door
    var key_item: PickupItem = _pickup_scene.instantiate()
    key_item.pickup_data = _key_data
    key_item.position = _in_level_position(previous_level)
    key_item.metadata[PickupItem.META_DOOR] = exit_door
    key_item.name = "Key_%d" % (previous + 1)
    previous_level.add_child(key_item)
    exit_door.key = key_item


    print("game_play: spawn entrance door on level %d, pos %s" % [current + 1, current_level.position])
    var entrance_door: Door = door_scene.instantiate()
    door_position = _door_position(current_level)
    current_level.contents[door_position] = Level.Content.DOOR
    entrance_door.position = Vector2((-Global.TILE_SIZE * current_level.level_width_half) + (door_position * Global.TILE_SIZE),0)
    entrance_door.is_exit = false
    entrance_door.name = "In_%d" % (current + 1)
    current_level.add_child(entrance_door)

    # link the doors
    entrance_door.linked_door = exit_door
    exit_door.linked_door = entrance_door


func _spawn_player(level_index: int) -> void:
    print("game_play: spawning player on level %d" % level_index)
    var level: Level = _level_buffer[_to_ind(level_index)]
    _player = player_scene.instantiate() as Player
    var pos: Vector2 = _in_level_position(level) + Vector2(0, MONSTER_SPAWN_Y_DISTANCE)
    _player.global_position = pos
    level.add_child(_player)

    _player_hud.player = _player

    EventBus.level_entered.emit(_player, level)
    $FollowCamera.follow_target = _player


func _door_position(level: Level) -> int:
    var other_door: int = level.contents.find(Level.Content.DOOR)
    var left_min: int = 2
    var right_max: int = level.level_width_half * 2 - 2
    var door_x: int = randi() % (right_max - left_min) + left_min
    if door_x < other_door - 2 or door_x > other_door + 2:
        return door_x
    else:
        return _door_position(level)


func _in_level_position(level: Level) -> Vector2:
    var left_min: int = 1
    var right_max: int = level.level_width_half * 2 - 1
    var x: int = randi() % (right_max - left_min) + left_min
    return Vector2((-Global.TILE_SIZE * level.level_width_half) + (x * Global.TILE_SIZE), 0)


func _on_level_entered(actor: Actor, level: Level) -> void:
    if actor is not Player:
        return

    _player_level = level.level_number

    if level.monster:
        _monster_hud.monster = level.monster

    _manage_level_buffer()


func _to_ind(num: int) -> int:
    return num % LEVELS_TO_BUFFER


func _spawn_monsters(data: LevelData) -> void:
    # Decide whether to spawn a monster based on chance
    if randf() > data.chance_for_monster:
        return # No monster this time

    var monster_index = Toolbox.pick_weighted_index(data.monster_weight)
    var monster_stats: ActorData = data.monsters[monster_index]
    var level: Level = _level_buffer[_to_ind(_last_level_index)]

    # TODO: There should be an enum that tells me the class from the ActorData
    var monster_instance: Actor = vermin_scene.instantiate()
    monster_instance.position = _in_level_position(_level_buffer[_to_ind(_last_level_index)])
    monster_instance.position += Vector2(0, MONSTER_SPAWN_Y_DISTANCE)
    monster_instance.data = monster_stats
    level.add_child(monster_instance)
    level.monster = monster_instance

func _spawn_weapons(data: LevelData) -> void:
    # Decide whether to spawn a weapon based on chance
    if randf() > data.chance_for_weapon:
        return # No weapon this time

    var weapon_index = Toolbox.pick_weighted_index(data.weapon_weight)
    var weapon_data: PickupData = data.weapons[weapon_index]
    var level: Level = _level_buffer[_to_ind(_last_level_index)]

    var weapon_instance: PickupItem = _pickup_scene.instantiate()
    weapon_instance.position = _in_level_position(_level_buffer[_to_ind(_last_level_index)])
    weapon_instance.pickup_data = weapon_data
    weapon_instance.name = "%s_%d" % [weapon_data.pickup_name, _last_level_index + 1]
    level.add_child(weapon_instance)


func _spawn_shields(data: LevelData) -> void:
    if randf() > data.chance_for_shield:
        return # No shield this time

    var shield_index = Toolbox.pick_weighted_index(data.shield_weight)
    var shield_data: PickupData = data.shields[shield_index]
    var level: Level = _level_buffer[_to_ind(_last_level_index)]

    var shield_instance: PickupItem = _pickup_scene.instantiate()
    shield_instance.position = _in_level_position(_level_buffer[_to_ind(_last_level_index)])
    shield_instance.pickup_data = shield_data
    shield_instance.name = "%s_%d" % [shield_data.pickup_name, _last_level_index + 1]
    level.add_child(shield_instance)


func _on_actor_killed(_actor: Actor) -> void:
    if _actor == _player:
        _player.queue_free()
        _fsm.send(Trigger.PLAYER_DIED)
        return

    _actor.queue_free()


func _on_game_over_dialog_quit_button_pressed() -> void:
    _fsm.send(Trigger.QUIT_TO_MENU)


func _on_game_over_dialog_try_again_button_pressed() -> void:
    _fsm.send(Trigger.TRY_AGAIN)


func _enter_game_over() -> void:
    _game_over_dialog.visible = true


func _exit_game_over() -> void:
    _game_over_dialog.visible = false


func _manage_level_buffer() -> void:
    # Ensure there are always enough levels ahead of the player
    # _spawn_level will handle freeing old levels when it starts
    # overwriting the ring buffer.
    while _last_level_index - _player_level < MIN_LEVELS_AHEAD:
        _spawn_next_level()


func _on_item_picked_up(actor: Actor, item: PickupItem) -> void:
    print("game_play: item %s picked up by actor %s" % [item.name, actor.name])

    match item.kind:
        PickupData.Kind.KEY:
            # when you pickup a key it unlocks the doors immediately
            var out_door: Door = item.metadata.get(PickupItem.META_DOOR)
            var in_door: Door = out_door.linked_door
            out_door.unlock()
            in_door.unlock()
            EventBus.door_unlocked.emit(out_door)
            EventBus.door_unlocked.emit(in_door)
        PickupData.Kind.WEAPON:
            pass
        PickupData.Kind.SHIELD:
            pass
        _:
            push_warning("game_play: unhandled item picked up kind %s" % [PickupData.Kind.keys()[item.kind]])


func _on_item_dropped(actor: Actor, item: PickupItem) -> void:
    print("game_play: item %s dropped by actor %s" % [item.name, actor.name])
    match item.kind:
        PickupData.Kind.KEY:
            # when you drop a key it locks the doors immediately
            var out_door: Door = item.metadata.get(PickupItem.META_DOOR)
            var in_door: Door = out_door.linked_door
            out_door.lock()
            in_door.lock()
            EventBus.door_locked.emit(out_door)
            EventBus.door_locked.emit(in_door)
        PickupData.Kind.WEAPON:
            pass
        PickupData.Kind.SHIELD:
            pass
        _:
            push_warning("game_play: unhandled item dropped kind %s" % [PickupData.Kind.keys()[item.kind]])


func _on_affector_activated(actor: Actor, affector: Affector) -> void:
    if actor is not Player or affector.kind != Global.AFFECTOR.HURT:
        return

    print("******** game_play: affector %s activated for player %s ***" % [Global.AFFECTOR.keys()[affector.kind], actor.name])
    pass


func _on_affector_cooldown_completed(actor: Actor, affector: Affector) -> void:
    if actor is not Player or affector.kind != Global.AFFECTOR.HURT:
        return

    print("******** game_play: affector %s cooldown completed for player %s ***" % [Global.AFFECTOR.keys()[affector.kind], actor.name])
    pass
