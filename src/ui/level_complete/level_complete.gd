@tool
class_name LevelComplete
extends UiPage

## Set by Level.win() before this page is shown. Empty means go to the main
## menu instead of a next level.
var next_level_scene: String = ""


func _ready() -> void:
	call_deferred("_connect_buttons")


func _connect_buttons() -> void:
	if ui:
		%NextLevel.pressed.connect(_next_level)
		%MainMenu.pressed.connect(_main_menu)


func _next_level() -> void:
	var target: String = next_level_scene if not next_level_scene.is_empty() else "res://src/main.tscn"
	await ui.hide_ui(self)
	ui.fade_to_scene(target)


func _main_menu() -> void:
	await ui.hide_ui(self)
	ui.fade_to_scene("res://src/main.tscn")
