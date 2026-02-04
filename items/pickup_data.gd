class_name PickupData
extends Resource

# Used to slot the item in an inventory
enum Kind
{
    NONE,
    KEY,
    WEAPON,
    SHIELD,
}

@export var pickup_name: String = "Unnamed Item"
@export var kind: Kind = Kind.NONE
@export var visual_texture: Texture2D
@export var attack: int = 0
@export var defense: int = 0
@export var attack_animation: String = ""
@export var hold_position: Vector2 = Vector2.ZERO
