extends Control

@onready var score_label = $VBoxContainer/LabelScore
@onready var combo_label = $VBoxContainer/LabelCombo

func _ready():
	# Set overall control size
	custom_minimum_size = Vector2(400, 120)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Create modern glass-like panel
	create_modern_panel()
	
	# Style the labels
	style_modern_label(score_label)
	style_modern_label(combo_label)
	
	# Connect to GameManager signals
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.combo_updated.connect(_on_combo_updated)
	
	# Initialize labels
	score_label.text = "SCORE: 0"
	combo_label.text = "COMBO: x1"

func create_modern_panel():
	# Create main container with gradient background
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.custom_minimum_size = Vector2(0, 100)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Create a modern glass effect
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.85)  # Dark blue-ish with transparency
	style.border_color = Color(0.3, 0.6, 1.0, 0.5)  # Light blue border
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	
	# Add shadow for depth
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 5)
	
	panel.add_theme_stylebox_override("panel", style)
	
	# Add glow effect
	var glow_panel = Panel.new()
	glow_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var glow_style = StyleBoxFlat.new()
	glow_style.bg_color = Color(0.2, 0.4, 1.0, 0.05)  # Subtle blue glow
	glow_style.draw_center = true
	glow_style.corner_radius_top_left = 15
	glow_style.corner_radius_top_right = 15
	glow_style.corner_radius_bottom_left = 15
	glow_style.corner_radius_bottom_right = 15
	glow_panel.add_theme_stylebox_override("panel", glow_style)
	
	# Add panels as children
	add_child(panel)
	move_child(panel, 0)
	panel.add_child(glow_panel)

func style_modern_label(label: Label):
	# Set font size and styling
	label.add_theme_font_size_override("font_size", 36)
	
	# Add glow effect with outline
	label.add_theme_color_override("font_outline_color", Color(0.3, 0.6, 1.0, 0.8))
	label.add_theme_constant_override("outline_size", 3)
	
	# Set text color
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	
	# Add shadow for text
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	
	# Center alignment
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Add minimum size
	label.custom_minimum_size = Vector2(300, 40)

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
