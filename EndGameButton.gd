extends Button

func _ready():
	# Always set up the button from scratch
	if GameManager.show_end_game_button:
		self.show()
	
	print("EndGameButton: Initializing")
	text = "END GAME"
	custom_minimum_size = Vector2(120, 40)
	
	# Disconnect any existing connections to avoid duplicates
	if is_connected("pressed", Callable(self, "_on_pressed")):
		disconnect("pressed", Callable(self, "_on_pressed"))
	
	# Connect the signal
	connect("pressed", Callable(self, "_on_pressed"))
	
	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.7, 0.1, 0.1, 0.8)
	style_normal.border_width_top = 2
	style_normal.border_width_right = 2
	style_normal.border_width_bottom = 2
	style_normal.border_width_left = 2
	style_normal.border_color = Color(0.9, 0.2, 0.2)
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.corner_radius_bottom_right = 5
	
	add_theme_stylebox_override("normal", style_normal)
	add_theme_font_size_override("font_size", 18)
	
	print("EndGameButton: Initialization complete")

func _on_pressed():
	# Debug print to see if the button is being pressed
	print("EndGameButton: PRESSED")
	
	# Make sure the GameManager is not already in an ended state
	if GameManager.game_ended:
		print("EndGameButton: Game already ended, ignoring")
		return
	
	# End the game
	print("EndGameButton: Calling end_game()")
	GameManager.end_game(false)
