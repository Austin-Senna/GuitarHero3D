extends Node3D

var short_note_scn = preload("res://note/short_note.tscn")
var long_note_scn = preload("res://note/long_note.tscn")
var note_scale 
var bar_data
var line
var speed

func _ready() -> void:
	add_notes()
	
func add_notes():
	line = 1
	if (bar_data!= null):
		for line_data in bar_data:	
			var notes_data = line_data.notes
			if (notes_data != null):
				for note_data in notes_data:
					add_note(line, note_data)
				line+=1
				
func add_note(line_local, data):
	var note_scn
	if int(data.len) >= 400:
		note_scn = long_note_scn
	else: 
		note_scn = short_note_scn
	
	var note = note_scn.instantiate()
	note.line =  line_local
	note.startingPosition =  int(data.pos)
	note.length = int(data.len)
	note.length_scale = note_scale
	note.speed = speed
	add_child(note)
	
