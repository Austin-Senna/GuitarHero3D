extends Node3D

@onready var bars_node = $BarsNode
var bar_length 
var bars = []
var bar_scn = preload("res://bar.tscn")
var current_location 
var speed
var deletion_z_threshold 
var note_scale

func setup(game):
	speed = Vector3(0,0, game.speed)
	bar_length = game.bar_length
	current_location = Vector3(0,0,-bar_length)
	deletion_z_threshold = 2.5 * bar_length
	note_scale = game.note_scale
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

func add_bar():
	var bar = bar_scn.instantiate()
	bar.set_position(Vector3(current_location.x, current_location.y, current_location.z))
	bar.note_scale = note_scale
	bars.append(bar)
	bars_node.add_child(bar)
	current_location += Vector3(0,0,-bar_length)
		
	
