@tool
extends UiPage

const REMAP_INPUT_BUTTON_SCENE: PackedScene = preload("res://src/ui/controls/remap_input_button.tscn")

@export var remap_mapping_contexts: Array[GUIDEMappingContext]
@export var icon_size: int:
	set(value):
		icon_size = value
		_formatter = GUIDEInputFormatter.new(icon_size)

var _audio_bus_name_idx_mapping: Dictionary = {}
var _remapper: GUIDERemapper = GUIDERemapper.new()
var _formatter: GUIDEInputFormatter
var _remapping_config: GUIDERemappingConfig

@onready var v_box_container: VBoxContainer = $ContentMarginContainer/VBoxContainer


func _ready() -> void:
	%InputPanel.visible = false
	if Engine.is_editor_hint():
		return
	# give top vbox a min x size so sliders get some room
	v_box_container.custom_minimum_size.x = get_viewport_rect().size.x * 0.5
	Settings.load_settings()
	%Back.pressed.connect(go_back)
	_init_audio_sliders()
	_update_audio_sliders.call_deferred()

	var project_theme: Theme = ThemeDB.get_project_theme()
	if not icon_size:
		icon_size = project_theme.default_font_size + 4 #2 *
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
	_remapping_config = Settings.load_controls()
	GUIDE.set_remapping_config(_remapping_config)
	_remapper.initialize(remap_mapping_contexts, _remapping_config)

	for context: GUIDEMappingContext in remap_mapping_contexts:
		var items: Array[GUIDERemapper.ConfigItem] = _remapper.get_remappable_items(context)
		for item: GUIDERemapper.ConfigItem in items:
			var action_label: Label = Label.new()
			action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			action_label.text = item.display_name
			action_label.custom_minimum_size.y = icon_size

			var remap_input: Control = REMAP_INPUT_BUTTON_SCENE.instantiate()
			remap_input.remapper = _remapper
			remap_input.formatter = _formatter
			remap_input.item = item
			%KeyboardMouseActions.add_child(action_label)
			%KeyboardMouseActions.add_child(remap_input)
			remap_input.button.pressed.connect(_get_new_input_for_action.bind(item))
			remap_input.button.custom_minimum_size = Vector2(icon_size, icon_size)


func _get_new_input_for_action(item: GUIDERemapper.ConfigItem) -> void:
	%InputPanel.item = item
	%InputPanel.size = get_viewport().get_visible_rect().size / 2
	%InputPanel.visible = true

	await %InputPanel.popup_hide
	var input: GUIDEInput = %InputPanel.input
	if input == null:
		return

	# check for collisions
	var collisions: Array[GUIDERemapper.ConfigItem] = _remapper.get_input_collisions(item, input)

	# if any collision is from a non-bindable mapping, we cannot use this input
	if collisions.any(func(it: GUIDERemapper.ConfigItem) -> bool: return not it.is_remappable):
		return

	# unbind the colliding entries.
	for collision: GUIDERemapper.ConfigItem in collisions:
		_remapper.set_bound_input(collision, null)

	# now bind the new input
	_remapper.set_bound_input(item, input)

	# we apply & save at every change
	var config: GUIDERemappingConfig = _remapper.get_mapping_config()
	GUIDE.set_remapping_config(config)
	Globals.controls_changed.emit(config)


#endregion
