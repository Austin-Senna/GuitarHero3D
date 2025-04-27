extends Node3D

@onready var pause_screen = load("res://Intro_Title_Menu/pause.tscn")

@onready var music_node = $Music
@onready var road_node = $road
@onready var world_env = $WorldEnvironment
@onready var environment = $WorldEnvironment.environment

var audio 
var map
var audio_file = GameManager.audio_file
var map_file = GameManager.map_file
var combo_lighting = load("res://world_environment/game_combo.tres")
var combo_glow 
var combo_color 
var normal_lighting = load ("res://world_environment/game.tres")
var normal_glow
var normal_color
var combo_environment = false
var game_started = false

var paused = false
var tempo 
var bar_length 
var quarter_time 
var speed 
var note_scale 
var start_time

func _ready():
	audio = load(audio_file)
	GameManager.audio_length = audio.get_length()
	
	
	map = load_map()
	calc_params()
	music_node.setup(self)
	road_node.setup(self)
	
	combo_color = combo_lighting.fog_light_color
	combo_glow = combo_lighting.glow_intensity
	normal_color = normal_lighting.fog_light_color
	normal_glow = normal_lighting.glow_intensity
	
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
	
func _process(delta) -> void:
	
	if (!paused):
		GameManager.current_time += delta
		
		if (game_started == false):
			if (GameManager.combo_count >= 1):
				set_normal()
				game_started = true
		if GameManager.combo_streak:
			set_combo()
		elif (combo_environment):
			set_normal()
			

		
func set_normal():
	combo_environment= false
	if not is_tween_active():
		var tween = create_tween()
		if is_instance_valid(environment):
			tween.tween_property(environment, "glow_intensity", normal_glow, 0.5)
			tween.tween_property(environment, "fog_light_color", normal_color, 0.5)
		environment.ambient_light_energy = 1.0 # Or your default value
		environment.tonemap_exposure = 1.0 # Or your default
	
		
func set_combo():
	if not is_tween_active():
		var tween = create_tween()
		var current_env = world_env.environment
		if is_instance_valid(current_env) and is_instance_valid(combo_lighting):
			tween.tween_property(current_env, "glow_intensity", combo_glow, 0.5)
			tween.tween_property(current_env, "fog_light_color", combo_color, 0.5)
			
		environment.ambient_light_energy = 0.5 # Adjust as needed
		environment.tonemap_exposure = 0.7 # Adjust for darkness
	combo_environment = true
		
func is_tween_active():
	for node in get_tree().get_nodes_in_group("tweens"):
		if is_instance_valid(node) and node.is_running():
			return true
	return false
