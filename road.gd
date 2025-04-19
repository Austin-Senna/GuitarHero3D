extends Node3D

@onready var bars_node = $BarsNode
var bar_length 
var bars = []
var bar_scn = preload("res://bar.tscn")
var curr_location 
var speed
var deletion_z_threshold 
var note_scale

var curr_bar_index
var tracks_data

func setup(game):
	speed = Vector3(0,0, game.speed)
	bar_length = game.bar_length
	curr_location = Vector3(0,0,-bar_length)
	deletion_z_threshold = 2.5 * bar_length
	note_scale = game.note_scale
	curr_bar_index = 0
	tracks_data = game.map.tracks
	add_bars()

func add_bars():
	for i in range(5):
		add_bar()
		
func _process(delta):
	# Every delta, bars_node moves by speed
	bars_node.translate(speed*delta)
	
	for bar in bars:
		if bar.global_position.z > deletion_z_threshold:
			remove_bar(bar)
			add_bar()

func remove_bar(bar):
	bar.queue_free()
	bars.erase(bar)

func get_bar_data():
	var key1 = tracks_data[0].bars[curr_bar_index]
	var key2 = tracks_data[1].bars[curr_bar_index]
	var key3 = tracks_data[2].bars[curr_bar_index]
	var key4 = tracks_data[3].bars[curr_bar_index]
	return [key1, key2, key3, key4]

func add_bar():	 
	var bar = bar_scn.instantiate()
	bar.set_position(Vector3(curr_location.x, curr_location.y, curr_location.z))
	bar.note_scale = note_scale
	bar.bar_data = get_bar_data()
	bars.append(bar)
	bars_node.add_child(bar)
	curr_location += Vector3(0,0,-bar_length)
	curr_bar_index += 1
		
	
