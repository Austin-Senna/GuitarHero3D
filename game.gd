extends Node3D

@onready var pause_screen = load("res://Intro_Title_Menu/pause.tscn")

@onready var music_node = $Music
@onready var road_node = $road
@onready var world_env = $WorldEnvironment
@onready var environment = $WorldEnvironment.environment
@onready var moon_material = load("res://world_environment/moon_material.tres")
var moon_base_color

var audio 
var map
var audio_file = GameManager.current_song.audio
var map_file = GameManager.current_song.map
var combo_lighting = load("res://world_environment/game_combo.tres")
var combo_glow 
var combo_color 
var normal_lighting = load ("res://world_environment/game.tres")
var normal_glow
var normal_color
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
	moon_base_color = moon_material.albedo_color
	moon_material.albedo_color.a = 0.0
	
	GameManager.streak_set.connect(_on_streak_set)
	GameManager.streak_fail.connect(_on_streak_fail)
	GameManager.song_finished.connect(_on_song_finished)
	
	# Create CanvasLayer for UI
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UILayer"
	add_child(canvas_layer)
	
	# Create and add the ScoreUI to the CanvasLayer
	var score_scene = load("res://ScoreUI.tscn")
	if score_scene:
		var score_instance = score_scene.instantiate()
		score_instance.anchors_preset = Control.PRESET_FULL_RECT
		canvas_layer.add_child(score_instance)  # Add to canvas_layer, not to self
	
	# Connect to music finished signal if it exists
	if music_node.has_signal("finished"):
		music_node.finished.connect(_on_song_finished)
	
	GameManager.start_game()
	
	get_tree().root.set_process_shortcut_input(true)
	
	print("Game setup complete - will intercept quit attempts")
	
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
	GameManager.end_game()
	
# If you want to save score when quitting
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Just quit directly, don't show analysis
		get_tree().quit()
		
# Also add this to handle in-game quit buttons if you have them
func _on_quit_button_pressed():
	_on_song_finished()
	
func _process(delta) -> void:
	if (!paused):
		GameManager.current_time += delta
		
		if (game_started == false):
			if (GameManager.combo_count >= 1):
				set_normal()
				game_started = true
				

func _on_streak_fail():
	set_normal()

func _on_streak_set():
	set_combo()

func set_normal():
	if not is_tween_active():
		var tween = create_tween()
		var target_color = moon_base_color
		target_color.a = 0.0
		tween.tween_property(moon_material, "albedo_color", target_color, 0.2)
		tween.tween_property(environment, "glow_intensity", normal_glow, 0.2)
		tween.tween_property(environment, "fog_sky_affect", 1, 0.2)
		tween.tween_property(environment, "fog_light_color", normal_color, 0.2)
		
		
		environment.ambient_light_energy = 1.0 # Or your default value
		environment.tonemap_exposure = 1.0 # Or your default
	
		
func set_combo():
	if not is_tween_active():
		var tween = create_tween()
		tween.tween_property(environment, "glow_intensity", combo_glow, 0.2)
		tween.tween_property(environment, "fog_sky_affect", 0.2, 0.2)
		tween.tween_property(environment, "fog_light_color", combo_color, 0.2)
		
		var target_color = moon_base_color
		target_color.a = moon_base_color.a # Fade In to original alpha
		tween.tween_property(moon_material, "albedo_color", target_color, 0.2)
				
		environment.ambient_light_energy = 0.5 # Adjust as needed
		environment.tonemap_exposure = 0.7 # Adjust for 
		
		
func is_tween_active():
	for node in get_tree().get_nodes_in_group("tweens"):
		if is_instance_valid(node) and node.is_running():
			return true
	return false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:  # Press F1 to open the data folder
			GameManager.open_data_folder()
