extends Node

# Constants for key types
enum KeyType {
	CORRECT,
	WRONG,
	MISSED,
	EXTRA
}

# Data structures
var actual_key_presses = []  # {time: float, key: String, type: KeyType}
var expected_key_presses = []  # {time: float, key: String}
var game_start_time = 0.0

func start_logging():
	actual_key_presses.clear()
	expected_key_presses.clear()
	game_start_time = Time.get_ticks_msec() / 1000.0

func log_key_press(key: String, is_correct: bool):
	var current_time = Time.get_ticks_msec() / 1000.0 - game_start_time
	actual_key_presses.append({
		"time": current_time,
		"key": key,
		"type": KeyType.CORRECT if is_correct else KeyType.WRONG
	})

func log_expected_key(key: String, time: float):
	expected_key_presses.append({
		"time": time,
		"key": key
	})

func log_missed_key(key: String, time: float):
	actual_key_presses.append({
		"time": time,
		"key": key,
		"type": KeyType.MISSED
	})

func get_analysis_data() -> Dictionary:
	# Analyze the data
	var total_notes = expected_key_presses.size()
	var correct_hits = 0
	var wrong_hits = 0
	var missed_notes = 0
	var extra_presses = 0
	
	# Count each type
	for press in actual_key_presses:
		match press.type:
			KeyType.CORRECT:
				correct_hits += 1
			KeyType.WRONG:
				wrong_hits += 1
			KeyType.MISSED:
				missed_notes += 1
			KeyType.EXTRA:
				extra_presses += 1
	
	# Calculate key-specific errors
	var key_errors = {
		"Q": {"missed": 0, "wrong": 0, "total": 0},
		"W": {"missed": 0, "wrong": 0, "total": 0},
		"E": {"missed": 0, "wrong": 0, "total": 0},
		"R": {"missed": 0, "wrong": 0, "total": 0}
	}
	
	# Count expected notes per key
	for expected in expected_key_presses:
		if expected.key in key_errors:
			key_errors[expected.key].total += 1
	
	# Count errors per key
	for actual in actual_key_presses:
		if actual.key in key_errors:
			if actual.type == KeyType.MISSED:
				key_errors[actual.key].missed += 1
			elif actual.type == KeyType.WRONG:
				key_errors[actual.key].wrong += 1
	
	return {
		"total_notes": total_notes,
		"correct_hits": correct_hits,
		"wrong_hits": wrong_hits,
		"missed_notes": missed_notes,
		"extra_presses": extra_presses,
		"key_errors": key_errors,
		"accuracy": float(correct_hits) / float(total_notes) * 100.0 if total_notes > 0 else 0.0
	}
