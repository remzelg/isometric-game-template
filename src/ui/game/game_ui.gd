@tool
extends UiPage

# TODO: Create your game's UI/HUD beginning here
# This UiPage is also responsible for pausing the game (and restoring UI state after)

# Note for aligning control in UI canvas layer to node in world:
# ui.control.global_position =
#		get_tree().current_scene.get_canvas_transform() * node.global_position

var _pushed_state: bool = false


func show_ui() -> void:
	if _pushed_state:
		_pushed_state = false
		ui.pop_state()
	super()


func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_back")):
		accept_event()
		_pause()


func _pause() -> void:
	if get_tree().paused:
		return
	get_tree().paused = true
	ui.push_state()
	_pushed_state = true
	ui.go_to("PauseMenu")
