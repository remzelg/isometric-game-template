extends Node

## Emitted by Settings when an action is remapped
@warning_ignore("unused_signal")
signal controls_changed()

## The currently active Game or Level node (whichever is in the "__Game__" group).
var game: Node2D:
	get():
		if not is_instance_valid(game):
			game = get_tree().get_first_node_in_group("__Game__")
		return game
