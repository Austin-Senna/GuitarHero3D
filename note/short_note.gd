extends "res://note/base_note.gd"

func on_process(delta):
	super.on_process(delta)  # Use super to call parent method
	if not is_collected:
		if is_colliding and picker:
			if picker.is_collecting:
				is_collected = true
				picker.is_collecting = false
				hide()
