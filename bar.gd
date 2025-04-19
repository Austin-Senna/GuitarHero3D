extends Node3D

var note_scn = preload("res://note/short_note.tscn")
var note_scale 
var bar_data
var line

func _ready() -> void:
	add_notes()
	
func add_notes():
	line = 1
	if (bar_data!= null):
		for line_data in bar_data:	
			var notes_data = line_data.notes
			if (notes_data != null):
				for note_data in notes_data:
					var note = note_scn.instantiate()
					note.line =  line
					note.startingPosition =  int(note_data.pos) * note_scale
					add_child(note)
				line+=1
		
			
