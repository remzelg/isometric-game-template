class_name AI extends Node

# needs to be updated on every call.
var grid: Grid
var board_state: Dictionary

func determine_action(character_id: String, current_tile: Vector2i, board: Board):
	grid = board.grid
	board_state = board.board_state
	
	if character_id.ends_with("badger"):
		return _badger_decision_tree(character_id, current_tile)
	elif character_id.ends_with("boar"):
		return _boar_decision_tree(character_id, current_tile)
	elif character_id.ends_with("stag"):
		return _stag_decision_tree(character_id, current_tile)
	else:
		return ["pass", null]

func _badger_decision_tree(character_id, current_tile):
	# cast ability if able to do so
	# attack anyone in melee range
	# move towards closest enemy
	# pass
	var adjacent_enemy_tiles = _adjacent_enemy_tiles(current_tile)
	var nearest_enemy_tile = _null_or_nearest_walkable_enemy_tile(character_id, current_tile)
	if _off_cooldown(character_id):
		return ["spell", "<spell_args_here>"]
	elif adjacent_enemy_tiles != []:
		return ["attack", adjacent_enemy_tiles[0]]
	elif nearest_enemy_tile:
		var path = grid.get_tile_path_from(current_tile, nearest_enemy_tile, true)
		
		return ["move", path.slice(0,2)]
	else:
		pass

func _boar_decision_tree(character_id, current_tile):
	# attack adjacent enemy if present
	var adjacent_enemy_tiles = _adjacent_enemy_tiles(current_tile)
	if adjacent_enemy_tiles != []:
		return ["attack", adjacent_enemy_tiles[0]]
	
	# move towards nearest enemy if possible
	var nearest_enemy_tile = _null_or_nearest_walkable_enemy_tile(character_id, current_tile)
	if nearest_enemy_tile:
		var path = grid.get_tile_path_from(current_tile, nearest_enemy_tile, true)
		return ["move", path.slice(0,2)]
	
	return ["pass", null]

func _stag_decision_tree(character_id, current_tile):
	var adjacent_enemy_tiles = _adjacent_enemy_tiles(current_tile)
	
	if adjacent_enemy_tiles != []:
		return ["attack", adjacent_enemy_tiles[0]]
	
	var nearest_enemy_tile = _null_or_nearest_enemy_tile(character_id, current_tile)
	if nearest_enemy_tile && _calculate_distance(current_tile,nearest_enemy_tile) < 4:
		return ["cast", ["fireball", nearest_enemy_tile]]
	
	var nearest_walkable_enemy_tile = _null_or_nearest_walkable_enemy_tile(character_id, current_tile)
	if nearest_walkable_enemy_tile:
		var path = grid.get_tile_path_from(current_tile, nearest_walkable_enemy_tile, true)
		return ["move", path.slice(0,2)]
	return ["pass", null]

# return true if characters ability is off cooldown
func _off_cooldown(character_id: String) -> bool:
	return false

# returns an array of tiles with enemies on them
# if none are present return []
func _adjacent_enemy_tiles(current_tile: Vector2i) -> Array[Vector2i]:
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
	]
	
	var adjacent_enemy_tiles: Array[Vector2i] = []
	var current_character_id = board_state[current_tile]
	
	for dir in directions:
		var adj_tile = current_tile + dir
		if board_state.has(adj_tile) and board_state[adj_tile] != null:
			var target_id = board_state[adj_tile]
			if !target_id.begins_with(current_character_id[0]):
				adjacent_enemy_tiles.push_back(adj_tile)
	
	return adjacent_enemy_tiles

# return the closest tile containing an enemy
# if no paths available return null
func _null_or_nearest_walkable_enemy_tile(character_id: String, current_tile: Vector2i):
	var closest_tile = null
	var min_path_length: int = 99
	var ally_prefix = character_id[0]
	
	for tile_pos in board_state:
		var target_character_id = board_state[tile_pos]
		
		# Skip characters on your own team or empty tiles
		if !target_character_id || target_character_id.begins_with(ally_prefix):
			continue
		
		# Get the path array of Vector2i points from your AStar grid
		var path: Array[Vector2i] = grid.get_tile_path_from(current_tile, tile_pos, true)

		# If the path is empty, the enemy is completely trapped/unreachable
		if path.is_empty():
			continue
			
		# The length of the array corresponds to the actual walking distance
		var path_length = path.size()
		if path_length < min_path_length:
			min_path_length = path_length
			closest_tile = tile_pos
	
	return closest_tile

# ignore pathing and find closest enemy tile
func _null_or_nearest_enemy_tile(character_id: String, current_tile: Vector2i):
	var closest_tile = null
	var min_distance: int = 99
	var ally_prefix = character_id[0]
	
	for tile_pos in board_state:
		var target_character_id = board_state[tile_pos]
		
		# Skip characters on your own team or empty tiles
		if !target_character_id || target_character_id.begins_with(ally_prefix):
			continue
		
		var distance = _calculate_distance(current_tile, tile_pos)
		
		if distance < min_distance:
			min_distance = distance
			closest_tile = tile_pos
	
	return closest_tile

func _calculate_distance(tile1: Vector2i, tile2: Vector2i):
	var x_diff = abs(tile1.x - tile2.x)
	var y_diff = abs(tile1.y - tile2.y)
	
	return x_diff + y_diff
