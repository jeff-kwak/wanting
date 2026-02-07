class_name LevelData
extends Resource


@export_category("Tileset and Appearance")
@export var tileset: TileSet
@export var wall_tile_coords: Array[Vector3i]
@export var floor_tile_coords: Array[Vector3i]
@export var base_tile_coords: Array[Vector3i]
@export var wall_top_tile_coords: Array[Vector3i]


@export_category("Chances")
@export_range(0.0, 1.0, 0.01)
var chance_for_monster: float = 0.1
@export_range(0.0, 1.0, 0.01)
var chance_for_weapon: float = 0.1
@export_range(0.0, 1.0, 0.01)
var chance_for_shield: float = 0.1
@export_range(0.0, 1.0, 0.01)
var chance_for_treasure: float = 0.1
@export_range(0.0, 1.0, 0.01)
var chance_for_chest: float = 0.1

@export_category("Monster Table")
@export var monster_weight: Array[float] = []
@export var monsters: Array[ActorData] = []

@export_category("Weapons")
@export var weapon_weight: Array[float] = []
@export var weapons: Array[PickupData] = []

@export_category("Shields")
@export var shield_weight: Array[float] = []
@export var shields: Array[PickupData] = []


@export_category("Treasures")
@export var treasure_weight: Array[float] = []
@export var treasures: Array[PickupData] = []
