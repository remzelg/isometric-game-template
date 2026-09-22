@tool
extends UiPage


func _ready() -> void:
	call_deferred("_connect_buttons")


func _connect_buttons() -> void:
	if ui:
		%Retry.pressed.connect(_retry)
		%MainMenu.pressed.connect(_main_menu)


func _retry() -> void:
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	await ui.hide_ui(self)
	ui.fade_to_scene(current_scene_path)


func _main_menu() -> void:
	await ui.hide_ui(self)
	ui.fade_to_scene("res://src/main.tscn")
