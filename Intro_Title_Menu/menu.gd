extends Control
@onready var animPlayer = $genericAnimation

func _ready() -> void:
	animPlayer.play_white_fade_in()
	animPlayer.play_menu_screen()
