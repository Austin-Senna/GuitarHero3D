extends Control

@onready var score_label = $%LabelScore
@onready var combo_label = $%LabelCombo
@onready var high_score_label = $%HighScoreLabel


func _ready():
	# Set overall control size
	custom_minimum_size = Vector2(400, 180)  # Increased height for high score
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Connect to GameManager signals
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.combo_updated.connect(_on_combo_updated)
	GameManager.high_score_broken.connect(_on_high_score_broken)
	GameManager.score_updated.connect(_on_check_high_score)
	
	# Initialize labels
	score_label.text = "SCORE: 0"
	combo_label.text = "COMBO: x1"
	high_score_label.text = "HIGH SCORE: " + str(int(GameManager.high_score))
	
func _on_score_updated(new_score):
	score_label.text = "SCORE: " + str(int(new_score))
	
	# Animate score increase
	if new_score > 0:
		var tween = create_tween()
		tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)
		
		# Flash color
		score_label.add_theme_color_override("font_color", Color(1, 1, 0.5))  # Golden
		await get_tree().create_timer(0.1).timeout
		score_label.add_theme_color_override("font_color", Color(1, 1, 1))

func _on_high_score_broken(new_high_score):
	high_score_label.text = "HIGH SCORE: " + str(int(new_high_score))
	
	# Create celebration animation
	var celebration = Label.new()
	celebration.text = "NEW HIGH SCORE!"
	celebration.add_theme_font_size_override("font_size", 48)
	celebration.add_theme_color_override("font_color", Color(1, 0.8, 0))
	celebration.add_theme_color_override("font_outline_color", Color(1, 0, 0))
	celebration.add_theme_constant_override("outline_size", 4)
	celebration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Position it in the center of the screen
	celebration.position = get_viewport_rect().size / 2 - Vector2(200, 50)
	celebration.z_index = 100
	add_child(celebration)
	
	# Animate the celebration
	var tween = create_tween()
	tween.tween_property(celebration, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(celebration, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_property(celebration, "modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.tween_callback(celebration.queue_free)
	
	# Flash the high score label
	var flash_tween = create_tween()
	flash_tween.tween_property(high_score_label, "modulate", Color(1, 1, 0), 0.2)
	flash_tween.tween_property(high_score_label, "modulate", Color(1, 1, 1), 0.2)
	flash_tween.set_loops(3)

func _on_combo_updated(new_combo):
	if new_combo >= GameManager.combo_threshold:
		var multiplier = 1 + float(new_combo) / GameManager.combo_threshold
		combo_label.text = "COMBO: x%.1f (%d)" % [multiplier, new_combo]
		
		# Rainbow effect for high combos
		if new_combo >= 20:
			var hue = fmod(float(new_combo) * 0.05, 1.0)
			combo_label.add_theme_color_override("font_color", Color.from_hsv(hue, 0.8, 1.0))
		else:
			combo_label.add_theme_color_override("font_color", Color(1, 0.6, 0.2))  # Orange
		
		# Pulse animation
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		combo_label.text = "COMBO: x1"
		combo_label.add_theme_color_override("font_color", Color(1, 1, 1))

func _on_check_high_score(current_score):
	if current_score > GameManager.high_score:
		high_score_label.text = "HIGH SCORE: " + str(int(current_score))
