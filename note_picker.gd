extends Node3D
@export_range(1, 4) var line = 1
var is_pressed = false
# Declare the material variables
var green_mat
var orange_mat
var pink_mat
var blue_mat
var is_collecting = false
var has_note_to_collect = false  # New variable

func _ready():
	# Load materials
	green_mat = load("res://green_picker_mat.tres")
	orange_mat = load("res://orange_picker_mat.tres")
	pink_mat = load("res://pink_picker_mat.tres")
	blue_mat = load("res://blue_picker_mat.tres")
	
	set_material()
	set_process_input(true)
	
	# Add picker to a group for detection
	$Area3D.add_to_group("picker")
	$Area3D.area_entered.connect(_on_note_entered)
	$Area3D.area_exited.connect(_on_note_exited)

func _on_note_entered(area: Area3D) -> void:
	if area.is_in_group("note"):
		has_note_to_collect = true

func _on_note_exited(area: Area3D) -> void:
	if area.is_in_group("note"):
		has_note_to_collect = false
	
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
					handle_key_press(event.pressed)
					get_viewport().set_input_as_handled()
			2:
				if event.keycode == KEY_W:
					handle_key_press(event.pressed)
					get_viewport().set_input_as_handled()
			3:
				if event.keycode == KEY_E:
					handle_key_press(event.pressed)
					get_viewport().set_input_as_handled()
			4:
				if event.keycode == KEY_R:
					handle_key_press(event.pressed)
					get_viewport().set_input_as_handled()

func handle_key_press(pressed: bool):
	is_pressed = pressed
	is_collecting = pressed
	
	# Check for miss (pressed key without note to collect)
	if pressed and not has_note_to_collect:
		GameManager.subtract_points()

func _process(_delta):
	if is_pressed:
		self.scale = Vector3(0.9, 0.9, 0.9)
	else:
		self.scale = Vector3(1, 1, 1)
