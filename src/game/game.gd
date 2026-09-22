class_name Game
extends Node2D
# This scene is started by clicking the "Play" button in main.tscn.
# Change Project Settings: application/run/start_scene to game/game.tscn to skip the menus while developing

# TODO: Create your game beginning here. For now, Play just drops straight
# into level1 - point this at your own content (or remove the redirect and
# build directly in this scene) when ready.


func _ready() -> void:
	get_tree().change_scene_to_file("res://src/game/level1.tscn")
