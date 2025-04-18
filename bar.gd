extends Node3D

var note_scn = preload("res://note.tscn")
var note_scale 

# max bar.length = 1600 * 0.005 = 8 
var notes_data = [
	{"pos": 0, len:"100"},
	{"pos": 400, len:"100"},
	{"pos": 800, len:"100"},
	{"pos": 1200, len:"100"}
]

func _ready() -> void:
	add_notes()
	
func add_notes():
	for note_data in notes_data:
		var note = note_scn.instantiate()
		note.line =  randi_range(1,4) 
		note.startingPosition = note_data.pos * note_scale
		add_child(note)
	
		
