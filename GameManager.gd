extends Node

# Score variables
var combo_streak = false
var current_points = 0
var combo_count = 0
var combo_multiplier = 1
var combo_threshold = 4
var high_score = 0

var audio_length = 0
var current_time = 0

var high_score_broken_this_game = false  # Track if high score was broken
var game_ended = false

var key_logger: Node

# Point values for different actions
var points_short_note = 100
var points_long_note_base = 200  # Base points for starting a long note
var points_long_note_per_second = 50  # Points per second of holding
var points_per_miss = -50
var points_per_missed_note = -50

var quitting = false
var analysis_ui = null
var analysis_showing = false

# Signals for UI updates
signal score_updated(new_score)
signal combo_updated(new_combo)
signal high_score_broken(new_high_score)

# File paths
var score_file_path = "res://score_history.txt"  # Changed from user:// to res://
var high_score_file_path = "res://high_score.txt"  # Changed from user:// to res://

# Audio file paths (keep existing references)
var audio_file = "res://audiotracks/linkinpark.ogg"
var map_file = "res://audiotracks/linkinpark.mboy"

func reset_game():
	print("GameManager: Reset game state")
	current_points = 0
	combo_count = 0
	combo_multiplier = 1
	high_score_broken_this_game = false
	game_ended = false          # Make sure this is reset
	analysis_showing = false    # If you have this variable
	
	# Reset key logger
	if key_logger:
		key_logger.start_logging()
	
	# Any other state variables that need to be reset
	
	# Debug print to confirm reset
	print("GameManager: Game state reset complete")

func _ready():
	current_points = 0
	combo_count = 0
	combo_multiplier = 1
	high_score_broken_this_game = false
	game_ended = false  # Reset the flag
	load_high_score()
	key_logger = load("res://KeyLogger.gd").new()
	add_child(key_logger)

func _process(delta):
	if (combo_count>=1):
		combo_streak = true
	else:
		combo_streak = false

func load_high_score():
	if FileAccess.file_exists(high_score_file_path):
		var file = FileAccess.open(high_score_file_path, FileAccess.READ)
		high_score = int(file.get_line())
		file.close()
	else:
		high_score = 0

func save_high_score():
	var file = FileAccess.open(high_score_file_path, FileAccess.WRITE)
	file.store_line(str(int(high_score)))  # Round to integer
	file.close()
	
func save_score_to_history():
	print("Saving score to history: ", current_points)  # Debug print
	
	var file
	if FileAccess.file_exists(score_file_path):
		file = FileAccess.open(score_file_path, FileAccess.READ_WRITE)
		if file:
			file.seek_end()  # Move to end of file to append
		else:
			print("Failed to open existing file for writing")
			return
	else:
		file = FileAccess.open(score_file_path, FileAccess.WRITE)
		if not file:
			print("Failed to create new file")
			return
	
	# Create timestamp
	var time = Time.get_datetime_dict_from_system()
	var timestamp = "%02d/%02d/%04d %02d:%02d:%02d" % [
		time.day, time.month, time.year,
		time.hour, time.minute, time.second
	]
	
	# Save score with timestamp - round the score to integer
	var score_line = timestamp + " - Score: " + str(int(current_points))
	file.store_line(score_line)
	file.close()
	
	print("Score saved successfully: ", score_line)  # Debug print
	
func end_game(quit_after: bool = false):
	if game_ended or analysis_showing:
		return
	
	game_ended = true
	analysis_showing = true
	
	# Save score
	save_score_to_history()
	
	# Show analysis UI
	show_performance_analysis()

func add_points_short_note():
	combo_count += 1
	update_combo_multiplier()
	
	var points_to_add = points_short_note * combo_multiplier
	current_points += points_to_add
	
	update_score()

func add_points_long_note(duration_seconds: float):
	combo_count += 1
	update_combo_multiplier()
	
	# Base points + duration bonus
	var base_points = points_long_note_base
	var duration_bonus = points_long_note_per_second * duration_seconds
	var total_points = (base_points + duration_bonus) * combo_multiplier
	
	current_points += total_points
	
	update_score()

func update_combo_multiplier():
	if combo_count >= combo_threshold:
		combo_multiplier = 1.0 + (float(combo_count) / float(combo_threshold)) * 0.1
	else:
		combo_multiplier = 1.0

func subtract_points():
	# Reset combo on miss
	combo_count = 0
	combo_multiplier = 1
	
	current_points += points_per_miss
	
	update_score()
	
func subtract_points_missed_note():
	# Reset combo on missed note
	combo_count = 0
	combo_multiplier = 1
	
	current_points += points_per_missed_note
	
	update_score()

func update_score():
	# Prevent negative scores
	current_points = max(0, current_points)
	
	# Check if high score was broken
	if current_points > high_score and not high_score_broken_this_game:
		high_score = current_points
		save_high_score()
		high_score_broken.emit(high_score)
		high_score_broken_this_game = true  # Set flag so it only happens once
	elif current_points > high_score:
		# Still update high score but don't emit signal
		high_score = current_points
		save_high_score()
	
	# Emit signals for UI updates
	score_updated.emit(current_points)
	combo_updated.emit(combo_count)
	
# Add new function to start logging
func start_game():
	key_logger.start_logging()
	# Reset other game variables as needed
	
func show_performance_analysis():
	var analysis_scene = load("res://PerformanceAnalysis.tscn")
	if analysis_scene:
		var analysis_instance = analysis_scene.instantiate()
		get_tree().current_scene.add_child(analysis_instance)
		analysis_instance.show_analysis()
	else:
		print("Failed to load PerformanceAnalysis scene")

func open_data_folder():
	OS.shell_open(get_user_data_directory())

func get_user_data_directory() -> String:
	return OS.get_user_data_dir()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("GameManager caught quit notification")
		if not game_ended:
			# Show analysis before quitting
			end_game(true)
			get_tree().set_auto_accept_quit(false)
		else:
			# Already analyzed, allow quitting
			get_tree().quit()
