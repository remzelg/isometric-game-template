extends Node2D

func _ready():
	var characters = get_tree().get_nodes_in_group("autobattler")
	
	for character in characters:
		if character.name == "GenericAnimal":
			pass
		else:
			var direction: String
			
			if character.character_id.begins_with("a_"):
				direction = "front"
			else:
				direction = "back"
			
			character.face(direction)
			character.play_animation("attack")
