extends Node

@export var tiles_per_second := 3

var tile_size: int

var current_tile: Vector2i
var target_tile: Vector2i
var moving := false

@onready var floor_layer = $"../../Dungeonfloor/TileMapLayer_Floor"
@onready var wall_layer  = $"../../DungeonWalls/TileMapLayer_Walls"


func _ready():
	

	# Use the floor layer's tile size. both layers use the same TileSet
	tile_size = floor_layer.tile_set.tile_size.x

	var parent := get_parent()

	# Convert world to tile using the floor layer
	current_tile = world_to_tile(parent.global_position)
	target_tile = current_tile

	# Snap to grid
	parent.global_position = tile_to_world(current_tile)


# TILE CONVERSION SYSTEM USING TILEMAPLAYERS

func world_to_tile(pos: Vector2) -> Vector2i:
	var local: Vector2 = floor_layer.to_local(pos)
	return floor_layer.local_to_map(local)


func tile_to_world(tile: Vector2i) -> Vector2:
	var local: Vector2 = floor_layer.map_to_local(tile)
	return floor_layer.to_global(local)

# MOVEMENT PROCESSING

func try_start_move(dir: Vector2i, is_walkable: Callable) -> bool:
	if moving or dir == Vector2i.ZERO:
		return false

	var next_tile = current_tile + dir

	if is_walkable.call(next_tile):
		target_tile = next_tile
		moving = true
		return true

	return false


func update_movement(delta: float) -> bool:
	if not moving:
		return false

	var parent := get_parent()
	var target_pos := tile_to_world(target_tile)

	var step := tiles_per_second * tile_size * delta
	parent.global_position = parent.global_position.move_toward(target_pos, step)

	if parent.global_position.distance_to(target_pos) < 1.0:
		parent.global_position = target_pos
		current_tile = target_tile
		moving = false
		return true

	return false
