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
	
	# Create CanvasLayer for UI
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UILayer"
	add_child(canvas_layer)
	
	# Create and add the ScoreUI to the CanvasLayer
	var score_scene = load("res://ScoreUI.tscn")
	if score_scene:
		var score_instance = score_scene.instantiate()
		canvas_layer.add_child(score_instance)  # Add to canvas_layer, not to self
	
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
