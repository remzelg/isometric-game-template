extends Level

# TODO: Replace the Win/Lose test buttons with real win/lose conditions.


func _ready() -> void:
	super()
	%Win.pressed.connect(win)
	%Lose.pressed.connect(lose)
