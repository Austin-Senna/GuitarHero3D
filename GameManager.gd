extends Node

# Score variables
var current_points = 0
var combo_count = 0
var combo_multiplier = 1
var combo_threshold = 10

# Point values for different actions
var points_short_note = 100
var points_long_note_base = 200  # Base points for starting a long note
var points_long_note_per_second = 50  # Points per second of holding
var points_per_miss = -50

# Signals for UI updates
signal score_updated(new_score)
signal combo_updated(new_combo)

# Audio file paths (keep existing references)
var audio_file = "res://audiotracks/linkinpark.ogg"
var map_file = "res://audiotracks/map.mboy"

func _ready():
	current_points = 0
	combo_count = 0
	combo_multiplier = 1

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

func update_score():
	# Prevent negative scores
	current_points = max(0, current_points)
	
	# Emit signals for UI updates
	score_updated.emit(current_points)
	combo_updated.emit(combo_count)
