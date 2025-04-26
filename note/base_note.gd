extends Node3D
@export_range(1, 4) var line = 1
var startingPosition = 0
@onready var cover = $AutobotEmblem/Bottom
@onready var noteShadow = $AutobotEmblem/Shading
# Declare the material variables
<<<<<<< Updated upstream
var green_mat = preload("res://note/green_note_mat.tres")
var orange_mat = preload("res://note/orange_note_mat.tres")
var pink_mat = preload("res://note/pink_note_mat.tres")
var blue_mat = preload("res://note/blue_note_mat.tres")
=======
var green_mat = preload("res://green_note_mat.tres")
var orange_mat = preload("res://orange_note_mat.tres")
var pink_mat = preload("res://pink_note_mat.tres")
var blue_mat = preload("res://blue_note_mat.tres")

>>>>>>> Stashed changes
var xPosition
var length
var length_scale
var speed 

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
	pass

func add_listeners():
	$Area3D.add_to_group("note")
	# Fix for Godot 4 signal connection syntax
	$Area3D.area_entered.connect(_on_area_entered)
	$Area3D.area_exited.connect(_on_area_exited)
	
func collect():
	is_collected = true
	GameManager.add_points_short_note()  # Update this line
	if picker:
		picker.is_collecting = false
	hide()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("picker"):
		is_colliding = true
		picker = area.get_parent()
		
func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("picker"):
		is_colliding = false
		picker = area.get_parent()
