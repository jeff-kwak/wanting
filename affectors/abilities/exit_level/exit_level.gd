class_name ExitLevelAbility
extends Affector

"""
An affector that allows an actor to exit the current level through a door.
"""

const PARAM_EXIT_DOOR: String = "exit_door"


func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.EXIT_LEVEL


func _on_activate(context := { }) -> bool:
    var out_door = context[PARAM_EXIT_DOOR]
    var in_door = out_door.linked_door

    if not out_door:
        push_error("exit_level: No exit door provided in context.")
        return false

    print("exit_level: Actor %s exiting level through door %s" % [actor.name, out_door.name])
    var dist: float = actor.global_position.distance_to(out_door.global_position)
    var duration: float = dist / actor.data.speed

    print("exit_level: Actor %s dropping key slot item before exiting level" % [actor.name])
    actor.activate_affector(Global.AFFECTOR.DROP_ITEM, { DropItemAbility.PARAM_ITEM: actor.key_slot })

    var tween: Tween = actor.create_tween()
    tween.tween_property(actor, "global_position", out_door.in_door_position, duration)
    await tween.finished
    var last_level: Level = out_door.get_parent() as Level
    print("exit_level: Actor %s removed from level %s" % [actor.name, last_level.name])
    actor.visible = false
    EventBus.level_exited.emit(actor, last_level)

    print("exit_level: Actor %s entered linked level through door %s" % [actor.name, in_door.name])
    var new_level: Level = in_door.get_parent() as Level
    actor.reparent(new_level, false)
    print("exit_level: Actor %s moved to level %s" % [actor.name, new_level.name])
    actor.move_to.call_deferred(in_door.in_door_position)
    await get_tree().process_frame
    if actor.global_position != in_door.in_door_position:
        push_error("exit_level: Actor %s position mismatch after moving to new level. Correcting." % [actor.name])
        actor.global_position = in_door.in_door_position
    actor.visible = true
    tween = actor.create_tween()
    tween.tween_property(actor, "global_position", in_door.threshold_position, duration)
    await tween.finished

    EventBus.level_entered.emit(actor, new_level)

    return false
