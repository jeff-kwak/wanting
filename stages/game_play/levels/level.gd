class_name Level
extends Node2D

enum Content
{
    EMPTY,
    DOOR,
}


@export var level_data: LevelData
@export var level_width_half: int = 9
@export var monster: Actor = null


@onready var _walls_and_floors: TileMapLayer = $WallsAndFloors


var contents: Array[Content] = []
var level_number: int = -1


func _init() -> void:
    contents.resize(level_width_half * 2)
    contents.fill(Content.EMPTY)


func _ready() -> void:
    # Setup the tilemap with the level data
    _walls_and_floors.tile_set = level_data.tileset

    for x in range(-level_width_half, level_width_half):
        #place the base
        var random_tile = _random_tile(level_data.base_tile_coords)
        _walls_and_floors.set_cell(Vector2i(x, 1), _source(random_tile), _atlas_coords(random_tile))

        #place the floors
        random_tile = _random_tile(level_data.floor_tile_coords)
        _walls_and_floors.set_cell(Vector2i(x, 0), _source(random_tile), _atlas_coords(random_tile))

        #place the walls
        random_tile = _random_tile(level_data.wall_tile_coords)
        _walls_and_floors.set_cell(Vector2i(x, -1), _source(random_tile), _atlas_coords(random_tile))

        #place the wall tops
        random_tile = _random_tile(level_data.wall_top_tile_coords)
        _walls_and_floors.set_cell(Vector2i(x, -2), _source(random_tile), _atlas_coords(random_tile))


func _random_tile(tile_coords: Array[Vector3i]) -> Vector3i:
    return tile_coords.pick_random()

func _source(tile_coord: Vector3i) -> int:
    return tile_coord.x

func _atlas_coords(tile_coord: Vector3i) -> Vector2i:
    return Vector2i(tile_coord.y, tile_coord.z)