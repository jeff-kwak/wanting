class_name Teleporter
extends Area2D

"""
Teleporters can teleporter actors to a destination
"""


@export var destination: Teleporter
@export var exit_direction: float = Vector2.RIGHT.x


var _inbound_actors: Array[Actor] = []


func receive(actor: Actor) -> void:
    _inbound_actors.append(actor)


func _on_area_exited(area: Area2D) -> void:
    print("teleporter: %s area exited by %s" % [self.name, area.name])
    var actor = area.get_parent() as Actor
    if actor and actor in _inbound_actors:
        _inbound_actors.erase(actor)
        print("teleporter: %s re-enabling CHANGE_DIRECTION affector for %s" % [self.name, actor.name])
        actor.enable_affector(Global.AFFECTOR.CHANGE_DIRECTION)


func _on_area_entered(area: Area2D) -> void:
    print("teleporter: %s area entered by %s" % [self.name, area.name])
    var actor = area.get_parent() as Actor
    if actor and actor not in _inbound_actors:
        if destination:
            actor.disable_affector(Global.AFFECTOR.CHANGE_DIRECTION)
            destination.receive(actor)
            actor.global_position = destination.global_position
            actor.facing_direction = destination.exit_direction
