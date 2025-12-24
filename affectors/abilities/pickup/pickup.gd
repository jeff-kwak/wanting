class_name PickupAbility
extends Affector

"""
An affector that allows an actor to pick up items.
"""

const PARAM_ITEM = "pickup_item"


func _get_kind() -> Global.AFFECTOR:
    return Global.AFFECTOR.PICKUP_ITEM


func _on_activate(context := { }) -> bool:
    var item: PickupItem = context[PARAM_ITEM]
    if item :
        if not item.can_be_picked_up:
            print("pickup_affector: item %s is on cooldown, cannot be picked up" % item.pickup_name)
            return false # item is on cooldown, cannot be picked up

        print("pickup_affector: actor %s picking up item %s" % [actor.name, item.pickup_name])
        actor.add_inventory(item)
        EventBus.item_picked_up.emit(actor, item)
        item.get_parent().remove_child(item)
        return true # has a cooldown

    return false
