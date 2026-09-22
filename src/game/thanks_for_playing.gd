extends Control
# A standalone scene shown after winning the last level. Any input returns to
# the main menu.

@export var thank_you_image: Texture2D:
	set(texture):
		thank_you_image = texture
		if is_instance_valid(texture_rect):
			texture_rect.texture = thank_you_image

@onready var texture_rect: TextureRect = %TextureRect


func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		UI.fade_to_scene("res://src/main.tscn")
