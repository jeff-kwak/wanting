class_name Actor
extends Node2D

"""
Base class for all actors in the game.
---
Actors are the containers for all character-related functionality.
The base class is like the puppet that abilities and affects
manipulate to create gameplay.
"""

@export var data: ActorData


var facing_direction: float = Vector2.RIGHT.x:
    get:
        return facing_direction
    set(value):
        facing_direction = value
        scale.x = facing_direction


var key_slot: PickupItem:
    get:
        return key_slot
    set(value):
        key_slot = value


var weapon_slot: PickupItem:
    get:
        return weapon_slot
    set(value):
        weapon_slot = value


var shield_slot: PickupItem:
    get:
        return shield_slot
    set(value):
        shield_slot = value


var wallet: int = 0:
    get:
        return wallet
    set(value):
        wallet = value


var current_health: int = 0:
    get:
        return current_health
    set(value):
        current_health = clamp(value, 0, max_health)
        if EventBus:
            EventBus.actor_current_health_changed.emit(self, current_health)


var max_health: int:
    get:
        return max_health
    set(value):
        max_health = value
        if EventBus:
            EventBus.actor_max_health_changed.emit(self, max_health)


var _affectors = { }


func _ready() -> void:
    for ability in $Abilities.get_children():
        if ability is Affector:
            _affectors[ability.kind] = ability

    for effect in $Effects.get_children():
        if effect is Affector:
            _affectors[effect.kind] = effect

    max_health = data.max_health
    current_health = max_health


### Actor action methods ###
func move_to(pos: Vector2) -> void:
    """
    Moves the actor to the specified position.
    """
    global_position = pos


func change_direction() -> void:
    """
    Changes the actor's facing direction by 180 degrees.
    """
    if facing_direction == Vector2.RIGHT.x:
        facing_direction = Vector2.LEFT.x
    else:
        facing_direction = Vector2.RIGHT.x


func add_inventory(item: PickupItem) -> void:
    """
    Adds the specified item to the actor's inventory or wallet.
    """
    print("actor: adding item %s (%s) to inventory of actor %s" % [item.pickup_name, item.name, self.name])
    item.reparent.call_deferred(self)
    item.call_deferred("set_position", Vector2.ZERO)
    item.hold.call_deferred()

    match item.kind:
        PickupData.Kind.KEY:
            key_slot = item
            _on_add_key_to_inventory()
        PickupData.Kind.WEAPON:
            if weapon_slot:
                activate_affector(Global.AFFECTOR.DROP_ITEM, { DropItemAbility.PARAM_ITEM: weapon_slot })
            weapon_slot = item
            data.attack += item.pickup_data.attack
            data.defense += item.pickup_data.defense # some weapons may change defense
            EventBus.actor_stats_changed.emit(self)
            _on_add_weapon_to_inventory()
        PickupData.Kind.SHIELD:
            if shield_slot:
                activate_affector(Global.AFFECTOR.DROP_ITEM, { DropItemAbility.PARAM_ITEM: shield_slot })
            shield_slot = item
            data.attack += item.pickup_data.attack # some shields may change attack
            data.defense += item.pickup_data.defense
            EventBus.actor_stats_changed.emit(self)
            _on_add_shield_to_inventory()
        PickupData.Kind.TREASURE:
            wallet += item.pickup_data.gold_value
            EventBus.actor_wallet_changed.emit(self, wallet)
            _on_add_money_to_wallet()
            # consume treasure immediately after adding to wallet
            item.queue_free()
        _:
            pass


func drop_item(item: PickupItem) -> void:
    """
    Drops the specified item from the actor's inventory into the game world.
    """
    print("actor: dropping item %s from inventory of actor %s" % [item.pickup_name, self.name])
    var level: Level = get_parent() as Level
    if not level:
        push_error("actor: cannot drop item %s, actor %s is not in a level!" % [item.pickup_name, self.name])
        return

    item.reparent.call_deferred(level)
    item.call_deferred("set_position", Vector2(position.x, 0))
    item.drop.call_deferred()

    match item.kind:
        PickupData.Kind.KEY:
            if key_slot == item:
                key_slot = null

        PickupData.Kind.WEAPON:
            if weapon_slot == item:
                weapon_slot = null

            data.attack -= item.pickup_data.attack
            data.defense -= item.pickup_data.defense # some weapons may change defense
            EventBus.actor_stats_changed.emit(self)

        PickupData.Kind.SHIELD:
            if shield_slot == item:
                shield_slot = null

            data.attack -= item.pickup_data.attack # some shields may change attack
            data.defense -= item.pickup_data.defense
            EventBus.actor_stats_changed.emit(self)

        _:
            push_error("actor: drop_item called with unsupported item kind %s" % PickupData.Kind.keys()[item.kind])
            pass


func drop_all_items() -> void:
    """
    Drops all items from the actor's inventory into the game world.
    """
    if key_slot:
        drop_item(key_slot)


func apply_damage(amount: int) -> void:
    """
    Applies damage to the actor, reducing its current health.
    """
    var affector: Affector = _affectors.get(Global.AFFECTOR.INVINCIBLE)
    if affector and affector.is_active:
        push_error("************ INVINCIBLE ************")
        print("actor: %s is invincible and takes no damage!" % self.name)
        return

    current_health = max(current_health - amount, 0)
    print("actor: %s took %d damage, current health is now %d" % [self.name, amount, current_health])
    EventBus.actor_current_health_changed.emit(self, current_health)
    if current_health <= 0:
        print("actor: %s has been slain!" % self.name)
        drop_all_items()
        _on_death()
    else:
        _on_hurt(amount)

### Affector management methods ###
func activate_affector(kind: Global.AFFECTOR, context := { }) -> void:
    if kind in _affectors:
        print("actor: activating affector %s for actor %s" % [Global.AFFECTOR.keys()[kind], self.name])
        _affectors[kind].activate(context)


func deactivate_affector(kind: Global.AFFECTOR) -> void:
    if kind in _affectors:
        print("actor: deactivating affector %s for actor %s" % [Global.AFFECTOR.keys()[kind], self.name])
        _affectors[kind].deactivate()


func deactivate_all_affectors() -> void:
    print("actor: deactivating all affectors for actor %s" % self.name)
    for kind in _affectors:
        _affectors[kind].deactivate()


func enable_affector(kind: Global.AFFECTOR) -> void:
    if kind in _affectors:
        print("actor: enabling affector %s for actor %s" % [Global.AFFECTOR.keys()[kind], self.name])
        _affectors[kind].enable()


func disable_affector(kind: Global.AFFECTOR) -> void:
    if kind in _affectors:
        print("actor: disabling affector %s for actor %s" % [Global.AFFECTOR.keys()[kind], self.name])
        _affectors[kind].disable()


func disable_all_affectors() -> void:
    print("actor: disabling all affectors for actor %s" % self.name)
    for kind in _affectors:
        _affectors[kind].disable()


### Sensoring and interaction methods ###
func _on_pickup_item_enter(_item: PickupItem) -> void:
    pass # To be overridden in subclasses


func _on_pickup_item_exit(_item: PickupItem) -> void:
    pass # To be overridden in subclasses


func _on_door_enter(_door: Door) -> void:
    pass # To be overridden in subclasses


func _on_door_exit(_door: Door) -> void:
    pass # To be overridden in subclasses


func _on_monster_enter(_monster: Actor) -> void:
    pass # To be overridden in subclasses


func _on_monster_exit(_monster: Actor) -> void:
    pass # To be overridden in subclasses


func _on_player_enter(_player: Actor) -> void:
    pass # To be overridden in subclasses


func _on_player_exit(_player: Actor) -> void:
    pass # To be overridden in subclasses


func _on_hurt(amount: int) -> void:
    EventBus.actor_hurt.emit(self, amount) # override in subclasses for more behavior


func _on_death() -> void:
    EventBus.actor_killed.emit(self) # override in subclasses for more behavior


func _on_add_key_to_inventory() -> void:
    pass # To be overridden in subclasses


func _on_add_weapon_to_inventory() -> void:
    pass # To be overridden in subclasses


func _on_add_shield_to_inventory() -> void:
    pass # To be overridden in subclasses


func _on_add_money_to_wallet() -> void:
    pass # To be overridden in subclasses


func _on_body_area_entered(area: Area2D) -> void:
    """
    Handles when a body area is entered. From the Area2D.
    Calls the appropriate item enter handler based on the type of the parent node.
    """
    var parent = area.get_parent()
    print("actor: body area entered %s" % parent.name)

    match parent:
        var item when item is PickupItem:
            _on_pickup_item_enter(item)
        var door when door is Door:
            _on_door_enter(door)
        var monster when monster is Actor and monster.is_in_group(Global.GROUP_MONSTER):
            _on_monster_enter(monster)
        var player when player is Actor and player.is_in_group(Global.GROUP_PLAYER):
            _on_player_enter(player)
        _:
            push_warning("actor: enter unhandled area type %s" % parent.name)


func _on_body_area_exited(area: Area2D) -> void:
    """
    Handles when a body area is exited. From the Area2D.
    Calls the appropriate item exit handler based on the type of the parent node.
    """
    var parent = area.get_parent()
    print("actor: body area exited %s" % parent.name)

    match parent:
        var item when item is PickupItem:
            _on_pickup_item_exit(item)
        var door when door is Door:
            _on_door_exit(door)
        var monster when monster is Actor and monster.is_in_group(Global.GROUP_MONSTER):
            _on_monster_exit(monster)
        var player when player is Actor and player.is_in_group(Global.GROUP_PLAYER):
            _on_player_exit(player)
        _:
            push_warning("actor: exit unhandled area type %s" % parent.name)
