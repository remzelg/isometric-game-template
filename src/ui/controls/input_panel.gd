extends PopupPanel

signal input_captured(event: InputEvent)

var action: StringName
var input: InputEvent


## Opens the panel and waits for the player to press a key, mouse button,
## controller button, or push a joystick axis. Returns null if cancelled.
func start(for_action: StringName) -> InputEvent:
	action = for_action
	input = null
	visible = true
	input = await input_captured
	visible = false
	return input


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		input_captured.emit(null)
		return

	var captured: InputEvent = _relevant_event(event)
	if captured:
		get_viewport().set_input_as_handled()
		input_captured.emit(captured)


func _relevant_event(event: InputEvent) -> InputEvent:
	if event is InputEventKey and event.pressed and not event.echo:
		return event
	if event is InputEventMouseButton and event.pressed:
		return event
	if event is InputEventJoypadButton and event.pressed:
		return event
	if event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		return event
	return null
