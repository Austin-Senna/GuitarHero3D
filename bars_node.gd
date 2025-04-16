extends Node3D

@onready var bars_node = $BarsNode
var bar_length = 8
var bars = []
var bar_scn = preload("res://bar.tscn")
var current_location = Vector3(0,0,0)
var speed = Vector3(0,0,2)
var deletion_z_threshold = 2.5 * bar_length 

func _ready():
	for i in range(4):
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
	bars.append(bar)
	bars_node.add_child(bar)
	current_location += Vector3(0,0,-bar_length)
		
	
