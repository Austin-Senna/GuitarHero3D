extends Node3D
@export_range(1, 4) var line = 1

var startingPosition = 0
# Declare the material variables
var green_mat = preload("res://green_note_mat.tres")
var orange_mat = preload("res://orange_note_mat.tres")
var pink_mat = preload("res://pink_note_mat.tres")
var blue_mat = preload("res://blue_note_mat.tres")
var xPosition

func _ready():	
	set_material()
	
	match line:
		1:
			xPosition = -1.5
		2:
			xPosition = -0.5
		3:
			xPosition = 0.5
		4:
			xPosition = 1.5
		
	self.set_position(Vector3(xPosition,0,-startingPosition))

	
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
