extends Node2D
@onready var player = $Dungeon/Testcharacter_Player
@onready var ally = $Dungeon/Testcharacter_Partymember
@onready var enemy = $Dungeon/Testcharacter_Enemy
@onready var testchar_collider = $Dungeon/Testcharacter/Testchar/CharacterBody2D
@onready var Dungeon = $Dungeon
@onready var dungeonfloor = $Dungeon/Dungeonfloor/TileMapLayer_Floor
@onready var dungeonwalls = $Dungeon/DungeonWalls/TileMapLayer_Walls
@onready var Testally_Pathfinder =  $Dungeon/Testcharacter_Partymember/TestAlly_NavigationAgent2D
@onready var charactermanager = $Charactermanager
@onready var enemy_pathfinder = $Dungeon/Testcharacter_Enemy/enemy_NavigationAgent2D

@onready var player_mover = player.get_node("GridMover")
@onready var ally_mover = ally.get_node("GridMover")
@onready var enemy_mover = enemy.get_node("GridMover")



#loads in the Debug Overlay objects
@onready var DebugOverlay_CurrentTurn = $"Debug Overlay/CurrentTurn"
@onready var DebugOverlay_CurrentTurnText = ""
@onready var DebugOverlay_Turncount =$"Debug Overlay/TurnCount"
@onready var DebugOverlay_TurncountText = ""

@onready var Movebuffer_x = 0
@onready var Movebuffer_y = 0

#Turn Mode Control Array
@onready var TurnModes = ["Player", "Party", "Enemy","Exit"]
#Current Turn Mode
@onready var CurrentTurn = ""
#Number of turns played
@onready var TurnCount = 0

#Party Member Array
@onready var PartyMembers = [ally]
#Enemy Array
@onready var ActiveEnemies = [enemy]
@onready var Ally_TargetPos = Vector2(0,0)
@export var movement_speed: float = 0.0
var movement_delta: float
var Ally_BasePos = Vector2(0,0)

#Enemy - Player Detection Radius
@export var detection_radius: int = 10
 

@export var tile_size: int = 100
@export var tiles_per_second: float = 2 #Movement rate, in tiles per second 
var moving: bool = false

var active_char = Node2D
var next_pos := Vector2(0,0)

#Tile variables
var current_tile: Vector2i
var target_tile: Vector2i
var last_player_tile: Vector2i

@onready var dungeon_tilemap: TileMap = $Dungeon/dungeontiles


#dungeon tilesets
@onready var tile_layers := [
		dungeonfloor,
		dungeonwalls
	]

func is_tile_walkable(tile_pos: Vector2i) -> bool:
	for layer in tile_layers:
		var tile_data = layer.get_cell_tile_data(tile_pos)

		if tile_data:
			#Read walkable. If it exists,continue the loop otherwise null
			var walkable = tile_data.get_custom_data("walkable") \
			if tile_data.has_custom_data("walkable") else null

			#WALLS BEHAVIOR: block if walkable is false OR missing
			if layer == dungeonwalls:
				if walkable == false or walkable == null:
					return false

			#FLOORS BEHAVIOR: block only if explicitly false
			if layer == dungeonfloor:
				if walkable == false:
					return false

	#Characters block tiles, and cannot be on the same tile.
	if is_tile_occupied(tile_pos):
		return false

	return true



#Manhattan Distance Calculation
func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

#Check function for tiles occupied by other characters
func is_tile_occupied(tile: Vector2i) -> bool:
	var movers = [
		player_mover,
		]

	for ally_node in PartyMembers:
		movers.append(ally_node.get_node("GridMover"))

	for enemy_node in ActiveEnemies:
		movers.append(enemy_node.get_node("GridMover"))

	for mover in movers:
		if mover.current_tile == tile:
			return true

	return false


#Player input check function
func player_has_input() -> bool:
	return Input.is_action_pressed("ui_up") \
		or Input.is_action_pressed("ui_down") \
		or Input.is_action_pressed("ui_left") \
		or Input.is_action_pressed("ui_right")

# PLAYER TURN PROCESSING AND MOVEMENT BEHAVIOR
func process_player_turn(delta):
	#If player is still moving, continue movement
	if player_mover.moving:
		player_mover.update_movement(delta)
		return !player_mover.moving
	#Player is idle. Proceed to check for input before continuing
	
	
	if player_has_input():
		var dir := Vector2i.ZERO

		if Input.is_action_just_pressed("ui_up"):
			dir = Vector2i(0, -1)
		elif Input.is_action_just_pressed("ui_down"):
			dir = Vector2i(0, 1)
		elif Input.is_action_just_pressed("ui_left"):
			dir = Vector2i(-1, 0)
		elif Input.is_action_just_pressed("ui_right"):
			dir = Vector2i(1, 0)

		if dir != Vector2i.ZERO:
			if player_mover.try_start_move(dir, is_tile_walkable):
				return false  # movement started
			return true       #movement failed. This still consumes turn
		else:
			return false
# PARTY MEMBER TURN PROCESSING AND MOVEMENT BEHAVIOR
func process_party_turn(delta):
	#Continue movement if already moving
	if ally_mover.moving:
		ally_mover.update_movement(delta)
		return not ally_mover.moving
	var agent = Testally_Pathfinder
	agent.target_position = player.global_position
	next_pos = agent.get_next_path_position()
	if next_pos == Vector2.ZERO:
		return true
	var next_tile = ally_mover.world_to_tile(next_pos)
	var raw_dir = next_tile - ally_mover.current_tile
	
	#Clamp to 1 tile of movement
	var dir := Vector2i(
		clamp(raw_dir.x, -1, 1),
		clamp(raw_dir.y, -1, 1))
		
	if dir == Vector2i.ZERO:
		return true
	
	#prevents movement to a tile another character is on
	if ally_mover.try_start_move(dir, is_tile_walkable):
		return false  # movement started

	return true  #movement failed. procee to end the turn.

	
func wander() -> bool:
	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0)
		]
	directions.shuffle()

	var tile :Vector2i = enemy_mover.current_tile

	for dir in directions:
		target_tile = tile + dir

		if is_tile_walkable(target_tile):
			if enemy_mover.try_start_move(dir, is_tile_walkable):
				return true  # movement started

	return true  #no valid direction proceed to end the turn

func chase(delta) -> bool:
	if enemy_mover.moving:
		enemy_mover.update_movement(delta)
		return not enemy_mover.moving

	var player_tile = player_mover.current_tile

	if player_tile != last_player_tile:
		enemy_pathfinder.set_target_position(player.global_position)
		last_player_tile = player_tile

	next_pos = enemy_pathfinder.get_next_path_position()
	if next_pos == Vector2.ZERO:
		return true

	# Convert the next waypoint into a tile coordinate
	var next_tile: Vector2i = enemy_mover.world_to_tile(next_pos)

	# Compute direction in Tile Space.
	var raw_dir: Vector2i = next_tile - enemy_mover.current_tile

	# Clamp to cardinal movement
	var dir := Vector2i(
		clamp(raw_dir.x, -1, 1),
		clamp(raw_dir.y, -1, 1)
	)

	# Prevent diagonal movement
	if abs(raw_dir.x) > abs(raw_dir.y):
		dir.y = 0
	else:
		dir.x = 0

	if dir == Vector2i.ZERO:
		return true

	target_tile = enemy_mover.current_tile + dir

	if not is_tile_walkable(target_tile):
		return true

	if enemy_mover.try_start_move(dir, is_tile_walkable):
		return false

	return true

# ENEMY CHARACTER TURN PROCESSING AND MOVEMENT BEHAVIOR
func process_enemy_turn(delta) -> bool:
	# If enemy is already moving, continue movement
	if enemy_mover.moving:
		enemy_mover.update_movement(delta)
		return not enemy_mover.moving
	var enemy_tile: Vector2i = enemy_mover.current_tile
	var player_tile: Vector2i = player_mover.current_tile
	var distance = manhattan_distance(enemy_tile, player_tile)
	if distance <= detection_radius:
		return chase(delta)
	else:
		return wander()


func _ready() -> void:
	#sets turn variables and debug text, and clears enemies on start
	PartyMembers = [ally]
	ActiveEnemies = [enemy]

	CurrentTurn = TurnModes[0]
	TurnCount = 1
	print(TurnCount)
	print(CurrentTurn)
	
	


func _physics_process(delta) -> void:
	#Updates the Debug Overlay
	DebugOverlay_TurncountText = var_to_str(TurnCount)
	DebugOverlay_CurrentTurnText = var_to_str(CurrentTurn)
	DebugOverlay_CurrentTurn.text = DebugOverlay_CurrentTurnText
	DebugOverlay_Turncount.text = DebugOverlay_TurncountText
	
	#Turn Order Processing and order management
	match CurrentTurn:
		"Player":
			if process_player_turn(delta):
				CurrentTurn = "Party"
		"Party":
			if process_party_turn(delta):
				CurrentTurn = "Enemy"
		"Enemy":
			if process_enemy_turn(delta):
				CurrentTurn = "Player"
				TurnCount += 1


	#Prints the turn count at end of turn.
	print(TurnCount)
	


	#Console debug functions
	print(enemy_pathfinder.target_position)
	print(enemy_pathfinder.target_reached)
	print(enemy_pathfinder.target_desired_distance)
		
		
		
	
