extends Node3D
@export_range(1, 4) var line = 1
var is_pressed = false

# Declare the material variables
var green_mat
var orange_mat
var pink_mat
var blue_mat

func _ready():
	# Load materials
	green_mat = load("res://green_mat.tres")
	orange_mat = load("res://orange_mat.tres")
	pink_mat = load("res://pink_mat.tres")
	blue_mat = load("res://blue_mat.tres")
	
	set_material()
	set_process_input(true)
	
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

func _input(event):
	if event is InputEventKey:
		match line:
			1:
				if event.keycode == KEY_Q:
					is_pressed = event.pressed
			2:
				if event.keycode == KEY_W:
					is_pressed = event.pressed
			3:
				if event.keycode == KEY_E:
					is_pressed = event.pressed
			4:
				if event.keycode == KEY_R:
					is_pressed = event.pressed

func _process(_delta):
	if is_pressed:
		self.scale = Vector3(0.9, 0.9, 0.9)
	else:
		self.scale = Vector3(1, 1, 1)
