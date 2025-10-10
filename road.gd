extends Node3D
# In an autoload singleton or main scene script
var road_shader_material = preload("res://road/road.tres")
var line_shader_material = preload("res://road/line.tres")
@onready var road = $RoadNode

func _ready():
	if road_shader_material.shader.code.length() > 0:
		pass # Just accessing it might help# Access the material to potentially trigger early loading/compilation
	GameManager.streak_set.connect(_on_streak_set)
	GameManager.streak_fail.connect(_on_streak_fail)
		
@onready var bars_node = $BarsNode
var bar_length 
var bars = []
var bar_scn = preload("res://bar.tscn")
var curr_location 
var speed
var deletion_z_threshold 
var note_scale
var combo_environment = false
var curr_bar_index
var tracks_data


func setup(game):
	speed = Vector3(0,0, game.speed)
	bar_length = game.bar_length
	curr_location = Vector3(0,0,-8)
	deletion_z_threshold = 2.5 * bar_length
	note_scale = game.note_scale
	curr_bar_index = 0
	tracks_data = game.map.tracks
	add_bars()
	
	road_shader_material.set_shader_parameter("scroll_speed", -speed.z/8.0) # 8 is length in meters of this plane mesh

func add_bars():
	for i in range(5):
		add_bar()
		
func _process(delta):
	# Every delta, bars_node moves by speed
	bars_node.translate(speed*delta)

	if (GameManager.current_time<= GameManager.audio_length):
		for bar in bars:
			if bar.global_position.z > deletion_z_threshold:
				remove_bar(bar)
				add_bar()
	
	
func _on_streak_set():
	road_shader_material.set_shader_parameter("activation_level", 0.15)
	
func _on_streak_fail():
	road_shader_material.set_shader_parameter("activation_level", 0)

func remove_bar(bar):
	bar.queue_free()
	bars.erase(bar)

func get_bar_data():
	var key1 = tracks_data[0].bars[curr_bar_index]
	var key2 = tracks_data[1].bars[curr_bar_index]
	var key3 = tracks_data[2].bars[curr_bar_index]
	
	var key4 
	if tracks_data.size() >= 4:
		key4 = tracks_data[3].bars[curr_bar_index]
	else:
		key4 = tracks_data[1].bars[curr_bar_index]
		
	return [key1, key2, key3, key4]

func add_bar():	 
	var bar = bar_scn.instantiate()
	bar.set_position(Vector3(curr_location.x, curr_location.y, curr_location.z))
	bar.note_scale = note_scale
	if (curr_bar_index < len(tracks_data[0].bars)):
		bar.bar_data = get_bar_data()
		bar.speed = speed
		bars.append(bar)
		bars_node.add_child(bar)
		curr_location += Vector3(0,0,-bar_length)
		curr_bar_index += 1
		
	
