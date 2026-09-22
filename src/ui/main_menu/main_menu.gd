@tool
extends UiPage

# TODO: Add a title and/or background art to main_menu.tscn


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	call_deferred("_connect_buttons")
	if OS.get_name() == "Web":
		%Exit.hide()


func _connect_buttons() -> void:
	if ui:
		%Play.pressed.connect(_start_game)
		%Settings.pressed.connect(ui.go_to.bind("Settings"))
		%Exit.pressed.connect(get_tree().call_deferred.bind("quit"))


func _start_game() -> void:
	ui.fade_to_scene("res://src/game/game.tscn")
