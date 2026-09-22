extends Button

var action: StringName:
	set(value):
		action = value
		refresh_text()


func refresh_text() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		text = "-"
		return
	var event: InputEvent = events[0]
	if event is InputEventKey:
		text = event.as_text_physical_keycode() if event.keycode == KEY_NONE else event.as_text_keycode()
	else:
		text = event.as_text()
