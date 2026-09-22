extends Node

signal input_device_changed(device: InputDevice)

enum InputDevice { UNKNOWN, KEYBOARD_MOUSE, CONTROLLER }

var last_input_device: InputDevice = InputDevice.UNKNOWN


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		_last_used(InputDevice.KEYBOARD_MOUSE)
	elif event is InputEventJoypadButton:
		_last_used(InputDevice.CONTROLLER)
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.3:
		_last_used(InputDevice.CONTROLLER)


func _last_used(device: InputDevice) -> void:
	if last_input_device != device:
		last_input_device = device
		input_device_changed.emit(device)
