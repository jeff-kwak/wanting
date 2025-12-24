@tool
class_name LevelCounterUi
extends Label


var level_number: int = 999:
    get:
        return level_number
    set(value):
        level_number = value
        text = "Level: %d" % (level_number + 1)


func _ready() -> void:
    level_number = level_number

    EventBus.level_entered.connect(_on_level_entered)


func _on_level_entered(actor: Actor, entered_level: Level) -> void:
    if actor is not Player:
        return

    level_number = entered_level.level_number

