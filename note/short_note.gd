extends "res://note/base_note.gd"

func collect():
	if not is_collected:  # Changed collected to is_collected
		if is_colliding and picker:
			if picker.is_collecting:
				is_collected = true  # Changed collected to is_collected
				picker.is_collecting = false
				hide()
