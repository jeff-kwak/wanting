class_name PickupData
extends Resource

enum Kind
{
    NONE,
    KEY,
}

@export var pickup_name: String = "Unnamed Item"
@export var kind: Kind = Kind.NONE
@export var visual_texture: Texture2D
