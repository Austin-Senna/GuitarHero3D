extends Node3D

var green_mat = preload("res://note/green_note_mat.tres") # TODO: green_beam_mat.tres has a visual bug, use note material for now
var orange_mat = preload("res://note/orange_note_mat.tres")
var pink_mat = preload("res://note/pink_note_mat.tres")
var blue_mat = preload("res://note/blue_note_mat.tres")
	
func set_material(line):
	print("Setting beam material for line:", line)
	match line:
		1:
			print("Green beam material exists:", green_mat != null)
			$MeshInstance3D.material_override = green_mat
		2:
			print("Orange beam material exists:", orange_mat != null)
			$MeshInstance3D.material_override = orange_mat
		3:
			print("Pink beam material exists:", pink_mat != null)
			$MeshInstance3D.material_override = pink_mat
		4:
			print("Blue beam material exists:", blue_mat != null)
			$MeshInstance3D.material_override = blue_mat
