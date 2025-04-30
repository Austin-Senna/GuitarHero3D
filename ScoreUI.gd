extends Control

@onready var score_label = $%LabelScore
@onready var combo_label = $%LabelCombo
@onready var high_score_label = $%HighScoreLabel
@onready var combo_count_label = $%LabelComboCount
@onready var transformers_font = preload("res://Intro_Title_Menu/Fonts/Transformers Movie.ttf")
@onready var game_progress_bar = $%GameProgressBar
@onready var combo_progress_bar = $%ComboProgressBar
@onready var animPlayer = $genericAnimation

var selected_song
var multiplier = 1.0
# Keep track of the last known streak count for animation triggers
var last_streak_count = -1
# Store the tween for the progress bar value to manage it
var progress_bar_value_tween : Tween

func _ready():
	# Set overall control size
	custom_minimum_size = Vector2(400, 180)  # Increased height for high score
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Connect to GameManager signals
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.combo_updated.connect(_on_combo_updated)
	GameManager.high_score_broken.connect(_on_high_score_broken)
	GameManager.score_updated.connect(_on_check_high_score)
	GameManager.streak_set.connect(_on_streak_set)
	GameManager.streak_fail.connect(_on_streak_fail)
	GameManager.pre_song_finished.connect(_pre_song_finished)
	
	# Initialize labels
	score_label.text = "SCORE: 0"
	combo_label.text = "x1.0"
	combo_count_label.text = "(0)"
	high_score_label.text = "HIGH SCORE: " + str(int(GameManager.high_score))
	
	animPlayer.play_white_fade_in()
	change_icon_and_title()
		
	
func change_icon_and_title():
	if (GameManager.audio_file == "res://audiotracks/linkinpark.ogg"):
		$%Icon.texture = load("res://Intro_Title_Menu/Images for Menu/LinkinPark.jpg")
		$%Title.text = "What I've Done"
		$%Singer.text = "~ Linkin Park"
	else:
		$%Icon.texture = load("res://Intro_Title_Menu/Images for Menu/twice.jpg")
		$%Title.text = "What Is Love"
		$%Singer.text = "~ Twice"
	
	
func _process(delta):
	game_progress_bar.value = GameManager.current_time/GameManager.audio_length * 100
	# --- Combo Progress Bar Update (Animated) ---
	var current_streak_count = GameManager.combo_streak_count
	var target_value = 0.0
	if GameManager.combo_streak_count_threshold > 0: # Avoid division by zero
		target_value = clampf(float(current_streak_count) / GameManager.combo_streak_count_threshold * 100.0, 0.0, 100.0)

	# Smoothly tween the value if it's different from the target
	if not is_equal_approx(combo_progress_bar.value, target_value):
		# Kill existing tween if it's running to start a new one immediately
		if progress_bar_value_tween and progress_bar_value_tween.is_valid():
			progress_bar_value_tween.kill()

		# Create a new tween for the value update
		progress_bar_value_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		# Adjust duration (e.g., 0.2 seconds) for desired smoothness
		progress_bar_value_tween.tween_property(combo_progress_bar, "value", target_value, 0.2)

	# --- Check for Streak Increase to Trigger Animations ---
	if current_streak_count > last_streak_count:
		# Trigger pulse/glow animation only on increase
		animate_combo_progress_bar_increase()

	# Update last known streak count for the next frame
	last_streak_count = current_streak_count

# --- Animation Function for Combo Progress Bar ---
func animate_combo_progress_bar_increase():
	# Don't animate if the bar is full or if streak count is zero (e.g., after reset)
	if GameManager.combo_streak_count <= 0 or is_equal_approx(combo_progress_bar.value, 100.0):
		return

	# --- Scale Pulse Animation ---
	# Ensure pivot is set correctly before scaling (might be needed if size changes)
	# combo_progress_bar.pivot_offset = combo_progress_bar.size / 2.0
	var scale_tween = create_tween()
	# Scale up quickly
	scale_tween.tween_property(combo_progress_bar, "scale", Vector2(1.01, 1.2), 0.1)\
			   .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT) # Slightly taller pop
	# Scale back to normal
	scale_tween.tween_property(combo_progress_bar, "scale", Vector2(1.0, 1.0), 0.1)\
			   .set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT) # Slight bounce back

	# --- Glow/Flash Animation (using modulate) ---
	var color_tween = create_tween()
	# Store the original progress tint (usually white = no tint)
	var original_tint = Color(0.8,0.8,0.8)
	# Use a bright color for the flash tint. Yellow often works well.
	var flash_tint_color = Color(1.0, 1.0, 1.0) # Bright Yellow
	# Or try pure white for max brightness:
	# var flash_tint_color = Color.WHITE

	# Fade to flash tint color
	color_tween.tween_property(combo_progress_bar, "tint_progress", flash_tint_color, 0.1)\
			   .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Fade back to original tint color
	color_tween.tween_property(combo_progress_bar, "tint_progress", original_tint, 0.1)\
			   .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _on_streak_set():
	var celebration = Label.new()
	celebration.text = "STREAK! (ALL POINTS X2)"
	celebration.add_theme_font_override("font", transformers_font)
	celebration.add_theme_font_size_override("font_size", 48)
	celebration.add_theme_color_override("font_color", Color(0, 0.8, 1))
	celebration.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	celebration.add_theme_constant_override("outline_size", 4)
	celebration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Position it in the center of the screen
	celebration.position = get_viewport_rect().size / 2 - Vector2(30, 50)
	celebration.z_index = 100
	add_child(celebration)
	
	# Animate the celebration
	var tween = create_tween()
	tween.tween_property(celebration, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(celebration, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_property(celebration, "modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.tween_callback(celebration.queue_free)
	
func _on_streak_fail():
	pass
	
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
	celebration.add_theme_font_override("font", transformers_font)
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
		combo_label.text = "x%.1f" % [GameManager.combo_multiplier]
		combo_count_label.text = "(%d)" % [GameManager.combo_count]
		
		# Rainbow effect for high combos
		if new_combo >= 20:
			var hue = fmod(float(new_combo) * 0.05, 1.0)
			combo_label.add_theme_color_override("font_color", Color.from_hsv(hue, 0.8, 1.0))
			combo_count_label.add_theme_color_override("font_color", Color.from_hsv(hue, 0.8, 1.0))
		else:
			combo_label.add_theme_color_override("font_color", Color(1, 0.6, 0.2))  # Orange
			combo_count_label.add_theme_color_override("font_color", Color(1, 0.6, 0.2))
		
		# Pulse animation
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		combo_label.text = "x1.0"
		combo_count_label.text = "(0)"  
		combo_label.add_theme_color_override("font_color", Color(1, 1, 1))
		combo_count_label.add_theme_color_override("font_color", Color(1, 1, 1))

func _on_check_high_score(current_score):
	if current_score > GameManager.high_score:
		high_score_label.text = "HIGH SCORE: " + str(int(current_score))

func _pre_song_finished():
	animPlayer.play_white_fade_out()
	
