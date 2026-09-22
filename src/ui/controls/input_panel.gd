extends PopupPanel

var item: GUIDERemapper.ConfigItem
var input: GUIDEInput

@onready var _input_detector: GUIDEInputDetector = %GUIDEInputDetector


func _ready() -> void:
	pass


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if not visible and is_instance_valid(_input_detector):
			_input_detector.abort_detection()
			return
		if not item:
			push_error("InputPanel missing GUIDERemapper.ConfigItem")
			visible = false
			return
		%KeyboardMouseLabel.visible = true
		var devices: Array[GUIDEInputDetector.DeviceType] = [
			GUIDEInputDetector.DeviceType.MOUSE, GUIDEInputDetector.DeviceType.KEYBOARD
		]
		_input_detector.detect(item.value_type, devices)
		input = await _input_detector.input_detected
		visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventAction and (event.is_action("ui_cancel") or event.is_action("ui_back")):
		get_viewport().set_input_as_handled()
		visible = false
