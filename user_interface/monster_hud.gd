class_name MonsterHud
extends Control


var monster: Actor:
    get:
        return monster
    set(value):
        monster = value
        _update_monster_info()


@onready var _name_label: Label = %MonsterName
@onready var _stats: ActorStatsUi = %ActorStats


func _ready() -> void:
    _update_monster_info()


func _update_monster_info() -> void:
    if not monster:
        visible = false
        return

    visible = true

    if _name_label:
        _name_label.text = monster.data.actor_name

    if _stats:
        _stats.actor = monster
