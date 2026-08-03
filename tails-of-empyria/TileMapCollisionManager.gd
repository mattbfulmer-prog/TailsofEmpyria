class_name TileMapCollisionManager
extends TileMap

# LITE VERSION — Full version adds batch methods (enable_layers_by_name,
# disable_layers_by_name), global toggles (disable_all_collision,
# enable_all_collision), and state serialization (get_collision_state_snapshot,
# restore_collision_state_snapshot) for save/load systems.
# Full version: https://nullstateassets.itch.io

# --- ARCHITECTURE NOTE ---
# TileMap.set_layer_enabled() operates on layer INDEX (0-based integer), but
# designers think in layer NAMES. This manager bridges that gap by resolving
# names to indices at runtime, eliminating the silent off-by-one bugs that
# plague manual index management across refactored tilemaps.

@export_category("TileMap Collision Manager")

@export_group("Initialization")
## When true, applies the initial_enabled_layers list immediately on _ready().
## Disable if you want to manage all state exclusively through code at runtime.
@export var apply_on_ready: bool = true

## Layer names that should have collision ENABLED when the scene loads.
## Any layer whose name is NOT in this list will have collision DISABLED.
## Leave empty to disable all layers on ready (useful for runtime-only control).
@export var initial_enabled_layers: Array[String] = []

@export_group("Diagnostics")
## Prints a warning to the Output panel when a requested layer name cannot be
## resolved to a valid index. Invaluable during scene setup; disable for
## shipping builds to silence the log.
@export var warn_on_missing_layer: bool = true

## Prints the full resolved name→index map to Output on _ready().
## Use this once to audit your tilemap's layer configuration, then turn it off.
@export var debug_print_layer_map: bool = false


# Cached name→index map built once on _ready(). Rebuilding this every call
# would be O(n) per operation; caching makes repeated runtime toggles O(1).
var _layer_index_map: Dictionary = {}


func _ready() -> void:
	_build_layer_index_map()

	if debug_print_layer_map:
		# Intentional diagnostic output — buyer explicitly opted in via Inspector.
		print("[TileMapCollisionManager] Layer index map: ", _layer_index_map)

	if apply_on_ready:
		_apply_initial_collision_state()


## Builds the internal name→index dictionary from the TileMap's current layer
## configuration. Must be called again if layers are added/removed at runtime
## via add_layer() or remove_layer() to keep the cache coherent.
func _build_layer_index_map() -> void:
	_layer_index_map.clear()
	var count: int = get_layers_count()
	for i: int in range(count):
		var name: String = get_layer_name(i)
		# Duplicate names are a TileMap editor quirk — last one wins here.
		# We warn so the buyer knows their layer naming is ambiguous.
		if _layer_index_map.has(name) and warn_on_missing_layer:
			push_warning(
				"[TileMapCollisionManager] Duplicate layer name '%s' detected. " +
				"Index %d will overwrite index %d in the cache. Rename your layers." %
				[name, i, _layer_index_map[name]]
			)
		_layer_index_map[name] = i


## Iterates every known layer and enables collision only for those whose names
## appear in initial_enabled_layers. This is an explicit whitelist model —
## unlisted layers are disabled — preventing stale editor state from leaking
## into runtime behavior.
func _apply_initial_collision_state() -> void:
	for layer_name: String in _layer_index_map.keys():
		var should_enable: bool = layer_name in initial_enabled_layers
		_set_collision_by_index(_layer_index_map[layer_name], should_enable)


## Resolves a layer name to its index and enables or disables its collision.
## Returns true if the layer was found and the operation succeeded.
## Returns false if the name could not be resolved (cache miss).
func set_collision_enabled_by_name(layer_name: String, enabled: bool) -> bool:
	if not _layer_index_map.has(layer_name):
		if warn_on_missing_layer:
			push_warning(
				"[TileMapCollisionManager] Layer name '%s' not found. " +
				"Valid names: %s" % [layer_name, _layer_index_map.keys()]
			)
		return false

	_set_collision_by_index(_layer_index_map[layer_name], enabled)
	return true


## Forces a full rebuild of the name→index cache. Call this after any runtime
## structural change to the TileMap (add_layer, remove_layer, set_layer_name)
## to prevent stale indices from causing silent misdirected collision toggles.
func refresh_layer_cache() -> void:
	_build_layer_index_map()
	if debug_print_layer_map:
		print("[TileMapCollisionManager] Cache refreshed. Layer index map: ", _layer_index_map)


## Internal single-responsibility setter. All public methods funnel through here
## so there is exactly one call site for set_layer_enabled() — if the engine
## API ever changes signature, only this line needs updating.
func _set_collision_by_index(index: int, enabled: bool) -> void:
	set_layer_enabled(index, enabled)
