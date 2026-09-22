class_name Level
extends Node2D
# Base class for a playable level. Shows the "Game" HUD/pause UI, and gives
# win()/lose() as the hook points for real win/lose conditions to call.

## Scene to load when "Next Level" is pressed after winning.
## Leave empty if this is the last level - winning it goes straight to the
## thank-you screen instead of showing the Level Complete page.
@export_file("*.tscn") var next_level_scene: String = ""


func _ready() -> void:
	add_to_group("__Game__")
	UI.go_to("Game")


func win() -> void:
	if next_level_scene.is_empty():
		UI.fade_to_scene("res://src/game/thanks_for_playing.tscn")
		return

	var level_complete: LevelComplete = UI.get_page("LevelComplete") as LevelComplete
	level_complete.next_level_scene = next_level_scene
	UI.go_to("LevelComplete")


func lose() -> void:
	UI.go_to("GameOver")
