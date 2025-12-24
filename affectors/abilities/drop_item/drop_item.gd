class_name DropItemAbility
extends Affector

"""
An affector that allows an actor to drop an item from their inventory.
"""

const PARAM_ITEM: StringName = "item"


func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.DROP_ITEM


func _on_activate(context := { }) -> bool:
    var item: PickupItem = context[PARAM_ITEM]
    if not item:
        return false # no item nothing to drop

    print("drop_item: actor %s dropping item %s" % [actor.name, item.name])
    item.start_pickup_cooldown()
    actor.drop_item(item)

    return false # instant effect, not active after application
