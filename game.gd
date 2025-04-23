extends Node3D

@onready var music_node = $Music
@onready var road_node = $road

var audio 
var map
var audio_file = GameManager.audio_file
var map_file = GameManager.map_file

var tempo 
var bar_length 
var quarter_time 
var speed 
var note_scale 
var start_time

func _ready():
	audio = load(audio_file)
	map = load_map()
	calc_params()
	music_node.setup(self)
	road_node.setup(self)
	
#120 bpm
func calc_params():
	tempo = int(map.tempo)
	bar_length = 16
	quarter_time = 60/float(tempo)
	speed = bar_length/float(4*quarter_time)
	note_scale = bar_length/float(4*400)
	start_time = 0 #float(map.start_pos)/400 * quarter_time
	
func load_map():
	var file = FileAccess.open(map_file, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json_result = JSON.parse_string(content) 
	return json_result
