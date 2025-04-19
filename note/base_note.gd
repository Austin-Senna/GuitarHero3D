extends Node3D
@export_range(1, 4) var line = 1
var startingPosition = 0
# Declare the material variables
var green_mat = preload("res://green_note_mat.tres")
var orange_mat = preload("res://orange_note_mat.tres")
var pink_mat = preload("res://pink_note_mat.tres")
var blue_mat = preload("res://blue_note_mat.tres")
var xPosition
var is_colliding = false
var picker
var is_collected = false

func _ready():
	on_ready()
	
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
		
	self.set_position(Vector3(xPosition, 0, -startingPosition))
	
func set_material():
	match line:
		1:
			$MeshInstance3D.material_override = green_mat
		2:
			$MeshInstance3D.material_override = orange_mat
		3:
			$MeshInstance3D.material_override = pink_mat
		4:
			$MeshInstance3D.material_override = blue_mat

func _process(delta):
	on_process(delta)

func on_process(delta):
	collect()

func add_listeners():
	$Area3D.add_to_group("note")
	# Fix for Godot 4 signal connection syntax
	$Area3D.area_entered.connect(_on_area_entered)
	$Area3D.area_exited.connect(_on_area_exited)
	
func collect():
	pass

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("picker"):
		is_colliding = true
		picker = area.get_parent()
		
func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("picker"):
		is_colliding = false
		picker = area.get_parent()
