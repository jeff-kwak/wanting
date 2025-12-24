class_name SideWalls
extends TileMapLayer

const SOURCE: int = 0
const RIGHT_WALL_1: Vector2i = Vector2i(0, 0)
const RIGHT_WALL_2: Vector2i = Vector2i(1, 0)
const RIGHT_WALL_3: Vector2i = Vector2i(0, 1)
const RIGHT_WALL_4: Vector2i = Vector2i(1, 1)
const LEFT_WALL_1: Vector2i = Vector2i(3, 0)
const LEFT_WALL_2: Vector2i = Vector2i(2, 0)
const LEFT_WALL_3: Vector2i = Vector2i(3, 1)
const LEFT_WALL_4: Vector2i = Vector2i(2, 1)

const WALL_X_SPACING: int = 10 # tile coords
const WALL_Y_SPACING: int = 16 # tile size


@export var walls_ahead: int = 15


@onready var _wall_depth: int = int(global_position.y)


var _wall_number: int = 0


func spawn_walls_to_position(depth_y: float) -> void:
    while _wall_depth <= depth_y:
        var right_pos: Vector2i = Vector2i(WALL_X_SPACING - 1, _wall_number)
        var left_pos: Vector2i = Vector2i(-WALL_X_SPACING, _wall_number)
        set_cell(right_pos, SOURCE, RIGHT_WALL_1)
        set_cell(right_pos + Vector2i.RIGHT, SOURCE, RIGHT_WALL_2)
        set_cell(right_pos + Vector2i.DOWN, SOURCE, RIGHT_WALL_3)
        set_cell(right_pos + Vector2i.RIGHT + Vector2i.DOWN, SOURCE, RIGHT_WALL_4)
        set_cell(left_pos, SOURCE, LEFT_WALL_1)
        set_cell(left_pos + Vector2i.LEFT, SOURCE, LEFT_WALL_2)
        set_cell(left_pos + Vector2i.DOWN, SOURCE, LEFT_WALL_3)
        set_cell(left_pos + Vector2i.LEFT + Vector2i.DOWN, SOURCE, LEFT_WALL_4)
        _wall_number += 2 # set a group of 2 tiles per wall
        _wall_depth += WALL_Y_SPACING * 2 # set a group of 2 vertical tiles
