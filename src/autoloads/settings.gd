extends Node

enum Section { AUDIO }

# Determines the size of the item components and their item slots for inventory toy
var item_size: Vector2i = Vector2i(60,60)

## Actions the Settings UI lets the player remap.
const REMAPPABLE_ACTIONS: Array[StringName] = [
	&"move_up", &"move_left", &"move_down", &"move_right", &"ui_back"
]

const SETTINGS_FILE: String = "user://settings.cfg"
const DEFAULT_SETTINGS_FILE: String = "res://default_settings.cfg"
const CONTROLS_SECTION: String = "Controls"

# Timer is used to prevent fast repeated saving of cfg files
var _timer: Timer
static var _settings: ConfigFile


func _ready() -> void:
	Globals.controls_changed.connect(save_controls)


#region control remapping
func load_controls() -> void:
	print("Loading controls from file...")
	load_settings()
	if not _settings.has_section(CONTROLS_SECTION):
		print("No saved controls data")
		return
	for action: StringName in REMAPPABLE_ACTIONS:
		var event: InputEvent = _settings.get_value(CONTROLS_SECTION, action, null)
		if event:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)


func save_controls() -> void:
	load_settings()
	for action: StringName in REMAPPABLE_ACTIONS:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if not events.is_empty():
			_settings.set_value(CONTROLS_SECTION, action, events[0])
	save_settings()


func reset_controls() -> void:
	load_settings()
	_settings.erase_section(CONTROLS_SECTION)
	save_settings()


#endregion


#region settings
func load_settings() -> void:
	if _settings != null:
		return
	_init_timer()
	_settings = ConfigFile.new()
	var err: int = _settings.load(SETTINGS_FILE)
	if err:
		print("Loading default settings")
		err = _settings.load(DEFAULT_SETTINGS_FILE)
		if not err:
			err = _settings.save(SETTINGS_FILE)


func _init_timer() -> void:
	_timer = Timer.new()
	_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_timer.one_shot = true
	_timer.timeout.connect(save_settings)
	add_child(_timer)


func save_settings() -> void:
	var err: int = _settings.save(SETTINGS_FILE)
	if err:
		printerr("Error saving settings '%s'" % str(err))


func get_value(section: Section, key: String, default: Variant) -> Variant:
	load_settings()
	var section_name: String = Section.keys()[section]
	return _settings.get_value(section_name.to_pascal_case(), key, default)


func set_value(section: Section, key: String, value: Variant) -> void:
	load_settings()
	var section_name: String = Section.keys()[section]
	_settings.set_value(section_name.to_pascal_case(), key, value)
	_timer.start(1.0)
#endregion
