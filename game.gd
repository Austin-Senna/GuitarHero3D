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
	
	# Connect to music finished signal if it exists
	if music_node.has_signal("finished"):
		music_node.finished.connect(_on_song_finished)
	
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
	
func _on_song_finished():
	# Call this when the song ends
	GameManager.end_game()
	
# If you want to save score when quitting
func _notification(what):
	# Handle only the quit request once
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if not GameManager.game_ended:  # Check if already saved
			GameManager.end_game()
		get_tree().quit()
		
# Also add this to handle in-game quit buttons if you have them
func _on_quit_button_pressed():
	GameManager.end_game()
	get_tree().quit()
