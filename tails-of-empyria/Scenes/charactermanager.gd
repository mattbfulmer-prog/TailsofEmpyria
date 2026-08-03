
var Active_Partymember = Sprite2D

var target_tile = Vector2i(0,0)

var movementspeed = 100
var closerange = movementspeed / 1.25
var gamemanager = "res://Scenes/Gamemanager.gd"
var current_tile: Vector2i
var moving: bool = false
var party_dir = Vector2i.ZERO

@export var tile_size: int = 25
@export var move_speed: float = 1  # tiles per second

var TurnModes = gamemanager.TurnModes
var CurrentTurn = ""
var TurnCount = 0

var active_char = Sprite2D



func moveprocess(character: Sprite2D):
		if moving and CurrentTurn == TurnModes[0]:
			move_toward_target(character,target_tile)
		elif CurrentTurn == TurnModes[0]:
			var dir = get_move_intent_Player()
			if dir != Vector2.ZERO:
				try_start_move(dir)

func get_move_intent_Player() -> Vector2:
	# Player VERSION (replace for NPC AI)
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input_dir.normalized()
	

func try_start_move(dir: Vector2):
	var next_tile = current_tile + Vector2i(dir)
	if is_tile_walkable(next_tile):
		target_tile = next_tile
		moving = true

func move_toward_target(ActiveCharacter: Sprite2D, target: Vector2i) -> void:
	var target_pos = tile_to_world(target_tile)
	var step = move_speed * tile_size
	ActiveCharacter.global_position = ActiveCharacter.move_toward(target_tile, step)
	if ActiveCharacter.global_position.distance_to(target_pos) < 0.5:
		ActiveCharacter.global_position = target_pos
		current_tile = target_tile
		moving = false
		
		
		
func get_move_intent_partymember(Partymember: Sprite2D, Player: Sprite2D) -> Vector2:
	determine_path(Partymember, Player) 
	
	party_dir = Vector2i.ZERO
	
	if target_tile == Vector2i (0,0):
		pass
	elif target_tile == Vector2i(Player.global_position. x + closerange, Player.global_position.y + closerange):
		party_dir.x = 1
		party_dir.y = 1
		
	elif target_tile == Vector2i(Player.global_position. x - closerange, Player.global_position.y - closerange):	
		party_dir.x = -1
		party_dir.y = -1
		
	elif target_tile == Vector2i(Player.global_position. x + closerange, Player.global_position.y - closerange):	
		party_dir.x = -1
		party_dir.y = 1
		
	elif target_tile == Vector2i(Player.global_position. x - closerange, Player.global_position.y + closerange):	
		party_dir.x = 1
		party_dir.y = -1
		
	elif target_tile == Vector2i(Player.global_position. x + closerange, Player.global_position.y + closerange):	
		party_dir.x = 1
		party_dir.y = -1
	
	elif target_tile == Vector2i(0, Player.global_position.y - closerange):
		party_dir.x = 0
		party_dir.y = 1
		
	elif target_tile == Vector2i(0, Player.global_position.y + closerange):
		party_dir.x = 0
		party_dir.y = -1
		
	elif target_tile == Vector2i(Player.global_position.x + closerange, 0):
		party_dir.x = 1
		party_dir.y = 0
		
	elif target_tile == Vector2i(Player.global_position.x - closerange, 0):
		party_dir.x = -1
		party_dir.y = 0
		
	return party_dir.normalized()
	
	
func world_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / tile_size), round(pos.y / tile_size))

func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size, tile.y * tile_size)

@warning_ignore("unused_parameter")
func is_tile_walkable(tile: Vector2i) -> bool:
	# Replace with your dungeon’s tilemap or room data
	return true


func determine_path(pathObject:Sprite2D, targeObject: Sprite2D):
	#var targetObject = Node2D
	var path_destination = Vector2i(0,0) 
	if targeObject.global_position.x > (pathObject.global_position.x + closerange) and targeObject.global_position.y > (pathObject.global_position.y + closerange): 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(targeObject.global_position. x + closerange, targeObject.global_position.y + closerange)
	elif targeObject.global_position.x < (pathObject.global_position.x - closerange) and targeObject.global_position.y > (pathObject.global_position.y + closerange): 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(targeObject.global_position. x + closerange, targeObject.global_position.y - closerange)
	elif targeObject.global_position.x > (pathObject.global_position.x + closerange) and targeObject.global_position.y < (pathObject.global_position.y - closerange): 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(targeObject.global_position. x - closerange, targeObject.global_position.y + closerange)
	elif targeObject.global_position.x == (pathObject.global_position.x - closerange) and targeObject.global_position.y == (pathObject.global_position.y + closerange): 
		path_destination = Vector2i(0,0)
	elif targeObject.global_position.x > (pathObject.global_position.x + closerange) and targeObject.global_position.y < (pathObject.global_position.y - closerange): 
		path_destination = Vector2i(0, 0)
	elif  (targeObject.global_position.x + closerange) == pathObject.global_position.x  and targeObject.global_position.y > (pathObject.global_position.y + closerange): 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(0, targeObject.global_position.y + closerange)
	elif  (targeObject.global_position.x - closerange) == pathObject.global_position.x  and targeObject.global_position.y > (pathObject.global_position.y - closerange): 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(0, targeObject.global_position.y - closerange)
	elif  targeObject.global_position.x  < pathObject.global_position.x - closerange  and targeObject.global_position.y - closerange == pathObject.global_position.y: 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(targeObject.global_position.x - closerange, 0)
	elif  (targeObject.global_position.x - closerange) == pathObject.global_position.x and targeObject.global_position.y - closerange == pathObject.global_position.y: 
		path_destination = Vector2i(0, 0)
	elif  targeObject.global_position.x < (pathObject.global_position.x - closerange) and targeObject.global_position.y > (pathObject.global_position.y + closerange):
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(targeObject.global_position. x - closerange, targeObject.global_position.y + closerange)
	elif targeObject.global_position.x < pathObject.global_position.x and (targeObject.global_position.y + closerange) == pathObject.global_position.y: 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(targeObject.global_position. x - closerange, 0)
	elif targeObject.global_position.x < (pathObject.global_position.x - closerange) and targeObject.global_position.y < (pathObject.global_position.y - closerange): 
		@warning_ignore("narrowing_conversion")
		path_destination = Vector2i(targeObject.global_position. x - closerange, targeObject.global_position.y - closerange)
	elif (targeObject.global_position.x + closerange) == pathObject.global_position.x and (targeObject.global_position.y + closerange) == pathObject.global_position.y: 
		path_destination = Vector2i(0, 0)
	elif (targeObject.global_position.x - closerange) == pathObject.global_position.x and (targeObject.global_position.y - closerange) == pathObject.global_position.y: 
		path_destination = Vector2i(0, 0)
	elif (targeObject.global_position.x + closerange) == pathObject.global_position.x and (targeObject.global_position.y == pathObject.global_position.y): 
		path_destination = Vector2i(0, 0)
	elif targeObject.global_position.x == pathObject.global_position.x and (targeObject.global_position.y + closerange) == pathObject.global_position.y: 
		path_destination = Vector2i(0, 0)
	elif (targeObject.global_position.x - closerange) == pathObject.global_position.x and (targeObject.global_position.y - closerange) == pathObject.global_position.y: 
		path_destination = Vector2i(0, 0)
	return path_destination
