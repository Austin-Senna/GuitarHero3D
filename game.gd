extends Node3D

@onready var music_node = $Music
@onready var road_node = $road

var audio 
var audio_file1 = "res://audiotracks/linkinpark.ogg"
#bpm = 120
var audio_file2 = "res://audiotracks/entersandman.mp3"
#bpm = 123

var tempo 
var bar_length 
var quarter_time 
var speed 
var note_scale 
var start_time

func _ready():
	audio = load(audio_file1)
	calc_params()
	music_node.setup(self)
	road_node.setup(self)
	
#120 bpm
func calc_params():
	tempo = 120
	bar_length = 8 
	quarter_time = 60/float(tempo)
	speed = bar_length/float(4*quarter_time)
	note_scale = bar_length/float(4*400)
	start_time = 0
