@tool
extends UiPage

const REMAP_INPUT_BUTTON_SCENE: PackedScene = preload("res://src/ui/controls/remap_input_button.tscn")

## Movement actions are shown together as one compact row instead of one row each.
const MOVE_ACTIONS: Array[StringName] = [&"move_up", &"move_left", &"move_down", &"move_right"]

const ACTION_DISPLAY_NAMES: Dictionary[StringName, String] = {
	&"ui_back": "Back",
}

var _audio_bus_name_idx_mapping: Dictionary = {}

@onready var v_box_container: VBoxContainer = $ContentMarginContainer/VBoxContainer
@onready var _input_panel: PopupPanel = %InputPanel


func _ready() -> void:
	%InputPanel.visible = false
	if Engine.is_editor_hint():
		return
	# give top vbox a min x size so sliders get some room
	v_box_container.custom_minimum_size.x = get_viewport_rect().size.x * 0.5
	Settings.load_settings()
	Settings.load_controls()
	%Back.pressed.connect(go_back)
	_init_audio_sliders()
	_update_audio_sliders.call_deferred()
	_init_actions()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		go_back()


#region Audio bus volumes
func _on_audio_hslider_value_changed(value: float, bus_name: String) -> void:
	#print(bus_name, value / 100)
	AudioServer.set_bus_volume_db(_audio_bus_name_idx_mapping[bus_name], linear_to_db(value / 100))
	if Settings.get_value(Settings.Section.AUDIO, bus_name, null) != value:
		Settings.set_value(Settings.Section.AUDIO, bus_name, value)


func _init_audio_sliders() -> void:
	for idx: int in range(0, AudioServer.bus_count):
		_audio_bus_name_idx_mapping[AudioServer.get_bus_name(idx)] = idx
	#print(JSON.stringify(_audio_bus_name_idx_mapping))

	for control: HSlider in %Audio.find_children("*", "HSlider"):
		control.value_changed.connect(_on_audio_hslider_value_changed.bind(control.name))


func _update_audio_sliders() -> void:
	for bus_name: String in _audio_bus_name_idx_mapping:
		var engine_level: float = db_to_linear(
			AudioServer.get_bus_volume_db(_audio_bus_name_idx_mapping[bus_name])
		)
		var settings_level: float = Settings.get_value(
			Settings.Section.AUDIO, bus_name, engine_level * 100
		)
		var control: Slider = %Audio.find_child(bus_name)
		if control:
			control.value = int(settings_level)


#endregion


#region Control remapping
func _init_actions() -> void:
	var move_row: HBoxContainer = HBoxContainer.new()
	move_row.add_theme_constant_override("separation", 4)
	for action: StringName in MOVE_ACTIONS:
		move_row.add_child(_make_remap_button(action))
	_add_action_row("Move", move_row)

	for action: StringName in Settings.REMAPPABLE_ACTIONS:
		if action in MOVE_ACTIONS:
			continue
		_add_action_row(ACTION_DISPLAY_NAMES.get(action, action.capitalize()), _make_remap_button(action))


func _add_action_row(label_text: String, control: Control) -> void:
	var action_label: Label = Label.new()
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	action_label.text = label_text
	%KeyboardMouseActions.add_child(action_label)
	%KeyboardMouseActions.add_child(control)


func _make_remap_button(action: StringName) -> Button:
	var remap_button: Button = REMAP_INPUT_BUTTON_SCENE.instantiate()
	remap_button.action = action
	remap_button.pressed.connect(_get_new_input_for_action.bind(action, remap_button))
	return remap_button


func _get_new_input_for_action(action: StringName, button: Button) -> void:
	var new_input: InputEvent = await _input_panel.start(action)
	if new_input == null:
		return

	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, new_input)
	button.refresh_text()
	Globals.controls_changed.emit()


#endregion
