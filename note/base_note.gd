extends Node3D
@export_range(1, 4) var line = 1
var startingPosition = 0
@onready var cover = $AutobotEmblem/Bottom
@onready var noteShadow = $AutobotEmblem/Shading
# Declare the material variables

var green_mat = preload("res://note/green_note_mat.tres")
var orange_mat = preload("res://note/orange_note_mat.tres")
var pink_mat = preload("res://note/pink_note_mat.tres")
var blue_mat = preload("res://note/blue_note_mat.tres")


var xPosition
var length
var length_scale
var speed 

var is_colliding = false
var picker
var is_collected = false
var to_hide_at = null

func _ready():
	on_ready()
	
	# Log this note as expected
	var key_name = ""
	match line:
		1: key_name = "Q"
		2: key_name = "W"
		3: key_name = "E"
		4: key_name = "R"
	
	var time_to_hit = startingPosition * length_scale / speed.z  # Calculate when note should be hit
	GameManager.key_logger.log_expected_key(key_name, time_to_hit)
	
func on_ready():
	set_material()
	add_listeners()
	
	match line:
		1:
			xPosition = -1.5
		2:
			xPosition = -0.5
		3:
			xPosition = 0.5
		4:
			xPosition = 1.5
		
	self.set_position(Vector3(xPosition, 0, -startingPosition*length_scale))
	
func set_material():
	match line:
		1:
			cover.material_override = green_mat
			noteShadow.material_override = green_mat
		2:
			cover.material_override = orange_mat
			noteShadow.material_override = orange_mat
		3:
			cover.material_override = pink_mat
			noteShadow.material_override = pink_mat
		4:
			cover.material_override = blue_mat
			noteShadow.material_override = blue_mat

func _process(delta):
	on_process(delta)

func on_process(_delta):
	process_hide_at()

func add_listeners():
	$Area3D.add_to_group("note")
	# Fix for Godot 4 signal connection syntax
	$Area3D.area_entered.connect(_on_area_entered)
	$Area3D.area_exited.connect(_on_area_exited)
	
func collect():
	is_collected = true
	GameManager.add_points_short_note()  # Update this line
	if picker:
		to_hide_at = picker.global_position.z
		picker.play_hit()
	
func process_hide_at():
	if is_collected and visible and to_hide_at != null:
		if global_position.z - to_hide_at >= 0:
			hide()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("picker"):
		is_colliding = true
		picker = area.get_parent()
		
func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("picker"):
		# If we're exiting the picker area and haven't been collected, we missed the note
		if not is_collected:
			var key_name = ""
			match line:
				1: key_name = "Q"
				2: key_name = "W"
				3: key_name = "E"
				4: key_name = "R"
			
			GameManager.key_logger.log_missed_key(key_name, Time.get_ticks_msec() / 1000.0)
			GameManager.subtract_points_missed_note()
		
		is_colliding = false
		picker = area.get_parent()
