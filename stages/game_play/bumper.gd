class_name Bumper
extends Area2D


func _on_area_entered(area: Area2D) -> void:
    var area_parent = area.get_parent()
    if area_parent is Actor:
        var actor: Actor = area_parent as Actor
        actor.activate_affector(Global.AFFECTOR.CHANGE_DIRECTION)

