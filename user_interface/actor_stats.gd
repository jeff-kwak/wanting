class_name ActorStatsUi
extends RichTextLabel

# [img]res://assets/0x72/attack-icon.png[/img]99[img]res://assets/0x72/defense-icon.png[/img]99
const STAT_TEMPLATE: String = "[img]res://assets/0x72/attack-icon.png[/img]{attack} [img]res://assets/0x72/defense-icon.png[/img]{defense}"

@export var actor: Actor:
    get:
        return actor
    set(value):
        actor = value
        _update_stats()


func _ready() -> void:
    EventBus.actor_stats_changed.connect(_on_actor_stats_changed)


func _on_actor_stats_changed(changed_actor: Actor) -> void:
    if changed_actor and actor and changed_actor == actor:
        _update_stats()


func _update_stats() -> void:
    if not actor:
        push_error("ActorStatsUi: No actor assigned.")
        return

    var stats := {
        "attack": "%2d" % actor.data.attack,
        "defense": "%2d" % actor.data.defense
    }

    if actor:
        text = STAT_TEMPLATE.format(stats)