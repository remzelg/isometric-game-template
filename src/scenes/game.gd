class_name TestGame extends Node2D

signal game_lost
signal game_won

@export var autoplay = true

var time_passed = 0
var previous_loop_complete = true
@onready var characters: Array[Node] = get_tree().get_nodes_in_group("autobattler") # array of character IDs

@onready var board: Board = _load_board("res://scenes/_debug/test_board.tscn")
@onready var display: Display = $"Display"
@onready var ai: AI = $"AI"

var input_capture: Control # initialized by parent

var remaining_animations_running = 0

func initialize(input_capture_node: Control):
	input_capture = input_capture_node
	
	# print out the input
	input_capture.board_click_requested.connect(_test_print)

func _test_print(arg):
	var tile = board.local_to_map(arg)
	print("clicked on " + str(tile))

func _ready():
	place("abadger", Vector2i(11,-1))
	place("astag", Vector2i(10,-1))
	place("bboar", Vector2i(11,3))
	place("bbboar", Vector2i(8,3))

func _process(delta):
	var mouse_position = get_global_mouse_position()
	var mouse_tile = board.map.local_to_map(mouse_position)
	if Input.is_action_just_pressed("left_click"):
		print(mouse_tile)
	
	board.map.clear_all_tiles()
	board.map.fill_tile(mouse_tile)
	
	if autoplay && board: # temporary, lets us turn off the autobattling
		time_passed += delta
		if time_passed > 1 && previous_loop_complete:
			previous_loop_complete = false
			time_passed = 0
			run_loop()

func run_loop():
	var chars = get_tree().get_nodes_in_group("autobattler")
	remaining_animations_running = chars.size()
	for character in chars:
		var player = character.get_node("AnimationPlayer")

		player.animation_finished.connect(func(anim_name):
			remaining_animations_running -= 1
			, CONNECT_ONE_SHOT)
	# Move forward with your game logic here
	for character in characters:
		var character_id = character.character_id
		var current_tile = board.get_location_of(character_id)
		var list_args = ai.determine_action(character_id, current_tile, board)
		var action: String = list_args[0]
		var action_arg = list_args[1]
		# all animals act simultaneously, update state while animations fire
		conduct_action(character_id, current_tile, action, action_arg)
	
	## Wait here until the counter hits zero
	while remaining_animations_running > 0:
		await get_tree().process_frame
		# play death animation if characters are dead
		for character in characters.filter(_is_dead):
			if !character.get_node("AnimationPlayer").is_playing():
				character.play_animation("die")
	if Flipper.enabled(Flipper.Feature.LOGGING):
		print("All action animations completed!")
	
	var a_animals = characters.filter(func(char): return char.character_id.begins_with("a"))
	var b_animals = characters.filter(func(char): return char.character_id.begins_with("b"))
	
	if b_animals.all(_is_dead):
		game_won.emit()
	if a_animals.all(_is_dead):
		game_lost.emit()
	
	var deaduns = characters.filter(_is_dead)
	for character in deaduns:
		clear(character, character.character_id)
	
	board.cleanup()
	previous_loop_complete = true

# TODO: Fade character out, remove them from board, remove sprite from group autobattlers
# trigger death animation before removing the sprite from the scene tree
func clear(character, character_id):
	pass

func conduct_action(character_id, current_tile, action, action_arg):
	if action == "move":
		var coords: Array[Vector2] = _tile_path_to_coords(action_arg)
		move(character_id, action_arg, coords)
	elif action == "attack":
		attack(character_id, current_tile, action_arg)
	elif action == "cast":
		cast(character_id, action_arg[0], current_tile, action_arg[1])
	elif action == "pass":
		idle(character_id)
	else: # if can't do anything
		pass

func place(character_id, tile):
	var coords = board.map_to_local(tile)
	
	board.place(character_id, tile) # add character_id to board state
	display.place(character_id, coords) # display sprite in appropriate starting position

func move(character_id, tiles, coords):
	if Flipper.enabled(Flipper.Feature.LOGGING):
		print(character_id + " moved to " + str(tiles[-1]))
	
	board.moving(character_id, tiles)
	display.move(character_id, coords)

func attack(character_id, origin_tile, target_tile):
	if Flipper.enabled(Flipper.Feature.LOGGING):
		print(character_id + " attacked " + str(target_tile))

	display.attack(character_id, origin_tile, target_tile)
	
	# TODO: Hook up state update to animation
	var target_id = board.board_state[target_tile]
	CharacterStateManager.adjust_health(target_id, -1)

# stored outside of a method because otherwise it gets garbage collected
var current_spell = load("res://src/resources/abilities/fireball.tres")

func cast(character_id, spell_id, origin_tile, target_tile):
	# hardcoded fireball
	var current_spell = load("res://src/resources/abilities/" + spell_id + ".tres")
	var target_id = board.board_state[target_tile]
	var target = _find_character(target_id)
	var targets: Array[Node] = [target]
	var caster = _find_character(character_id)
	
	current_spell.cast(caster, targets, origin_tile, target_tile)

func idle(character_id):
	if Flipper.enabled(Flipper.Feature.LOGGING):
		print(character_id + " idled")
	
	display.idle(character_id)

#region Private
func _find_character(character_id):
	var characters = get_tree().get_nodes_in_group("autobattler")
	
	for character in characters:
		if character.character_id == character_id:
			return character
	
	return null

func _is_dead(character):
	return character.get_node("HealthBar").value <= 0

func _tile_path_to_coords(tiles) -> Array[Vector2]:
	var coords: Array[Vector2] = []
	for tile in tiles:
		coords.push_back(board.map_to_local(tile))
	
	return coords

func _load_board(path):
	var woom = get_node_or_null("Board")
	if woom:
		return woom
	else:
		var scene = load(path)
		var board_inst = scene.instantiate()
		
		add_child(board_inst)
		return board_inst
#endregion
