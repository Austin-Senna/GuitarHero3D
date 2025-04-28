extends Control

var gemini_api: Node
@onready var analysis_label = $VBoxContainer/ScrollHolder/ScrollContainer/AnalysisLabel
@onready var close_button = $VBoxContainer/CloseButton
@onready var play_again_button = $VBoxContainer/PlayAgainButton
@onready var title_label = $VBoxContainer/TitleLabel
@onready var scroll_container = $VBoxContainer/ScrollHolder/ScrollContainer
var api_response_received = false

func _ready():
	# Make UI fullscreen
	anchors_preset = Control.PRESET_FULL_RECT
	visible = true
	
	# Set semi-transparent background
	var background = $Background
	background.color = Color(0.1, 0.1, 0.15, 0.85)  # Semi-transparent dark blue
	
	# Style the title
	title_label.add_theme_font_size_override("font_size", 40)
	title_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))  # Gold color
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	
	# Style analysis text
	analysis_label.add_theme_font_size_override("font_size", 18)
	analysis_label.add_theme_color_override("font_color", Color(1, 1, 1))
	
	# Style buttons
	play_again_button.add_theme_font_size_override("font_size", 20)
	close_button.add_theme_font_size_override("font_size", 20)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.4, 0.6)
	
	# Set borders individually
	btn_style.border_width_top = 2
	btn_style.border_width_right = 2
	btn_style.border_width_bottom = 2
	btn_style.border_width_left = 2
	btn_style.border_color = Color(0.3, 0.5, 0.8)

	# Set corners individually
	btn_style.corner_radius_top_left = 10
	btn_style.corner_radius_top_right = 10
	btn_style.corner_radius_bottom_left = 10
	btn_style.corner_radius_bottom_right = 10
	
	play_again_button.add_theme_stylebox_override("normal", btn_style.duplicate())
	
	var exit_style = btn_style.duplicate()
	exit_style.bg_color = Color(0.6, 0.2, 0.2)
	exit_style.border_color = Color(0.8, 0.3, 0.3)
	close_button.add_theme_stylebox_override("normal", exit_style)
	
	setup_scrolling()
	
	# Initialize Gemini API
	gemini_api = load("res://GeminiAPI.gd").new()
	add_child(gemini_api)
	gemini_api.response_received.connect(_on_analysis_received)
	gemini_api.error_occurred.connect(_on_analysis_error)
	
	
	# Connect buttons using direct callable approach
	close_button.connect("pressed", Callable(self, "_on_exit_pressed"))
	play_again_button.connect("pressed", Callable(self, "_on_play_again_pressed"))

	# Enable input processing for backup button handling
	set_process_input(true)


func setup_scrolling():
	print("Setting up scrolling...")
	
	var scroll_container = $VBoxContainer/ScrollHolder/ScrollContainer
	var analysis_label = $VBoxContainer/ScrollHolder/ScrollContainer/AnalysisLabel
	
	if not scroll_container or not analysis_label:
		print("ERROR: Scroll structure not found!")
		return
	
	# Ensure the ScrollContainer allows vertical scrolling
	if "vertical_scroll_mode" in scroll_container:
		scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	else:
		# Fallback for older Godot versions
		scroll_container.set("scroll/horizontal", false)
		scroll_container.set("scroll/vertical", true)
	
	# Make the label expand to fill width of scroll container
	analysis_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Ensure the label can be larger than its container
	analysis_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Set a very large minimum height to force scrolling
	analysis_label.custom_minimum_size = Vector2(scroll_container.size.x, 2000)
	
	# Ensure the ScrollContainer has enough height
	var scroll_holder = $VBoxContainer/ScrollHolder
	scroll_holder.custom_minimum_size = Vector2(600, 400)
	
	# Try to find and configure the scrollbar (version-agnostic approach)
	for child in scroll_container.get_children():
		if child is VScrollBar:
			child.custom_minimum_size.x = 20
			child.visible = true
			break
	
	print("Scroll setup complete")

func show_analysis():
	# Pause the game while showing analysis
	get_tree().paused = true
	
	# Make sure our UI still works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Parse the analysis text for better formatting
	analysis_label.text = "Analyzing your performance..."
	
	# Get analysis data
	var analysis_data = GameManager.key_logger.get_analysis_data()
	
	# Save initial data to file
	save_analysis_to_file(analysis_data)
	
	# Send to Gemini API
	gemini_api.analyze_performance(analysis_data)

func save_analysis_to_file(data: Dictionary):
	var file = FileAccess.open("res://performance_analysis.txt", FileAccess.WRITE)
	if file:
		var time = Time.get_datetime_dict_from_system()
		var timestamp = "%02d/%02d/%04d %02d:%02d:%02d" % [
			time.day, time.month, time.year,
			time.hour, time.minute, time.second
		]
		
		file.store_line("=== Performance Analysis - " + timestamp + " ===")
		file.store_line("Total Notes: " + str(data.total_notes))
		file.store_line("Correct Hits: " + str(data.correct_hits))
		file.store_line("Accuracy: %.1f%%" % data.accuracy)
		file.store_line("Wrong Keys: " + str(data.wrong_hits))
		file.store_line("Missed Notes: " + str(data.missed_notes))
		file.store_line("")
		file.store_line("Waiting for AI analysis...")
		file.close()
	else:
		print("Failed to open file for writing")

func _on_analysis_received(response: String):
	api_response_received = true
	
	# Don't use BBCode since it's not working correctly
	var formatted_text = "PERFORMANCE ANALYSIS\n\n"
	formatted_text += "Scroll down to see all recommendations\n\n"
	formatted_text += "----------------------------------------\n\n"
	
	# Format without BBCode
	var sections = response.split("\n\n")
	for section in sections:
		if section.begins_with("1.") or section.begins_with("The top"):
			formatted_text += "CRITICAL ISSUES:\n" + section + "\n\n"
		elif section.begins_with("2.") or section.begins_with("Practice"):
			formatted_text += "PRACTICE RECOMMENDATIONS:\n" + section + "\n\n"
		elif section.begins_with("3.") or section.begins_with("Recommended"):
			formatted_text += "TRAINING PLAN:\n" + section + "\n\n"
		elif section.begins_with("4.") or section.begins_with("Encouragement"):
			formatted_text += "ENCOURAGEMENT:\n" + section + "\n\n"
		else:
			formatted_text += section + "\n\n"
	
	analysis_label.text = formatted_text
	
	# Save to file (plain text version)
	var file = FileAccess.open("res://performance_analysis.txt", FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		file.store_line("")
		file.store_line("=== AI Coach Feedback ===")
		file.store_line(response)
		file.store_line("")
		file.store_line("=".repeat(50))
		file.close()
	
	force_scroll_update()

func _on_analysis_error(error: String):
	api_response_received = true
	analysis_label.text = "Error analyzing performance: " + error
	
	# Generate offline analysis as fallback
	var analysis_data = GameManager.key_logger.get_analysis_data()
	var offline_analysis = generate_offline_analysis(analysis_data)
	
	analysis_label.text = offline_analysis + "\n\n(Generated offline due to API error: " + error + ")"

func generate_offline_analysis(data: Dictionary) -> String:
	var analysis = "PERFORMANCE ANALYSIS (Offline Mode)\n\n"
	
	# Calculate overall accuracy
	var accuracy = data.accuracy
	
	# Identify weakest key
	var lowest_key = "Q"
	var lowest_accuracy = 100.0
	
	for key in ["Q", "W", "E", "R"]:
		var total = data.key_errors[key].total
		if total > 0:
			var correct = total - data.key_errors[key].missed - data.key_errors[key].wrong
			var key_accuracy = (float(correct) / float(total) * 100.0) if total > 0 else 0.0
			if key_accuracy < lowest_accuracy:
				lowest_accuracy = key_accuracy
				lowest_key = key
	
	# Generate basic feedback
	analysis += "Overall accuracy: %.1f%%\n\n" % accuracy
	
	if accuracy < 40:
		analysis += "CRITICAL ISSUES:\n"
		analysis += "1. Low overall accuracy - focus on basic timing\n"
		analysis += "2. Difficulty with %s key (%.1f%% accuracy)\n" % [lowest_key, lowest_accuracy]
		analysis += "3. High number of missed notes (%d)\n\n" % data.missed_notes
		
		analysis += "PRACTICE RECOMMENDATIONS:\n"
		analysis += "1. Slow down the game speed to build muscle memory\n"
		analysis += "2. Focus on single-key exercises for the %s key\n" % lowest_key
		analysis += "3. Try the tutorial mode to improve timing\n\n"
	elif accuracy < 70:
		analysis += "AREAS FOR IMPROVEMENT:\n"
		analysis += "1. Moderate accuracy - work on consistency\n"
		analysis += "2. Pay special attention to %s key\n" % lowest_key
		analysis += "3. %d wrong key presses - check hand positioning\n\n" % data.wrong_hits
		
		analysis += "PRACTICE RECOMMENDATIONS:\n"
		analysis += "1. Practice shorter, focused sessions\n"
		analysis += "2. Alternate between slow practice and normal speed\n"
		analysis += "3. Record your playthroughs to analyze mistakes\n\n"
	else:
		analysis += "STRENGTHS AND REFINEMENTS:\n"
		analysis += "1. Good overall accuracy - focus on perfecting technique\n"
		analysis += "2. Even at your skill level, the %s key needs attention\n" % lowest_key
		analysis += "3. Consider increasing difficulty for more challenge\n\n"
		
		analysis += "PRACTICE RECOMMENDATIONS:\n"
		analysis += "1. Try more complex songs\n"
		analysis += "2. Work on multi-key combinations\n"
		analysis += "3. Practice sight-reading new songs\n\n"
	
	analysis += "ENCOURAGEMENT:\n"
	analysis += "Keep up the good work! Regular practice and targeted exercises will help you improve steadily."
	
	return analysis

func _on_play_again_pressed():
	# Unpause the game first
	get_tree().paused = false
	
	# Reset game state
	GameManager.reset_game()
	
	# Return to the game scene
	get_tree().change_scene_to_file("res://game.tscn")
	
	# Remove analysis UI
	queue_free()

func _on_exit_pressed():
	# Unpause before quitting
	get_tree().paused = false
	
	# Quit when explicitly requested by user
	get_tree().quit()
	
func format_section(text: String, color_code: String) -> String:
	var lines = text.split("\n")
	var result = "[b][color=#" + color_code + "]" + lines[0] + "[/color][/b]\n"
	
	for i in range(1, lines.size()):
		result += lines[i] + "\n"
	
	return result + "\n"

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var close_rect = close_button.get_global_rect()
		var play_rect = play_again_button.get_global_rect()
		
		if close_rect.has_point(event.position):
			print("Close button clicked via input handler")
			_on_exit_pressed()
		elif play_rect.has_point(event.position):
			print("Play again button clicked via input handler")
			_on_play_again_pressed()
			
func force_scroll_update():
	await get_tree().process_frame
	await get_tree().process_frame
	
	var scroll_container = $VBoxContainer/ScrollHolder/ScrollContainer
	if scroll_container:
		# Force scroll to top using multiple potential methods
		if "scroll_vertical" in scroll_container:
			scroll_container.scroll_vertical = 0
		elif scroll_container.has_method("set_v_scroll"):
			scroll_container.set_v_scroll(0)
