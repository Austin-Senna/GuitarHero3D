extends Node3D
@export_range(1, 4) var line = 1

var is_pressed = false
# Declare the material variables
var green_mat
var orange_mat
var pink_mat
var blue_mat

var green_activated_mat
var orange_activated_mat
var pink_activated_mat
var blue_activated_mat
var base_position

var is_collecting = false
var has_note_to_collect = false  # New variable
@onready var trigger = $EmblemPicker/TopPixelated
@onready var emblem = $EmblemPicker/Autobots_001
@onready var picker_cover = $EmblemPicker/BottomColor
@onready var fail_player = $FailSound
@onready var hit_player = $HitSound
@onready var vfx_scene = load("res://vfx_scene.tscn")

func _ready():
	# Load materials
	green_mat = load("res://green_picker_mat.tres")
	orange_mat = load("res://orange_picker_mat.tres")
	pink_mat = load("res://pink_picker_mat.tres")
	blue_mat = load("res://blue_picker_mat.tres")
	green_activated_mat = load("res://note/green_note_mat.tres")
	orange_activated_mat = load("res://note/orange_note_mat.tres")
	pink_activated_mat = load("res://note/pink_note_mat.tres")
	blue_activated_mat = load("res://note/blue_note_mat.tres")
	base_position = picker_cover.position
	
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

func set_picker(material):
	picker_cover.material_override = material
	emblem.material_override = material
	
func translate_trigger(vector):
	var base_trigger = base_position + Vector3(0,-0.15,0)
	var base_emblem = base_position + Vector3(0,-0.12,0)
	emblem.position = vector + base_emblem
	trigger.position = vector + base_trigger

func set_material_activated():
	match line:
		1:
			set_picker(green_activated_mat)
		2:
			set_picker(orange_activated_mat)
		3:
			set_picker(pink_activated_mat)
		4:
			set_picker(blue_activated_mat)
			
func set_material():
	match line:
		1:
			set_picker(green_mat)
		2:
			set_picker(orange_mat)
		3:
			set_picker(pink_mat)
		4:
			set_picker(blue_mat)

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
	
	if pressed:
			# Log the key press (from your Kaan branch)
		var key_name = ""
		match line:
			1: key_name = "Q"
			2: key_name = "W"
			3: key_name = "E"
			4: key_name = "R"
		
		# Log the key press for analysis
		GameManager.key_logger.log_key_press(key_name, has_note_to_collect)
		
func play_hit():
	hit_player.play()
	var vfx_instance = vfx_scene.instantiate()
	add_child(vfx_instance)
	# Position the VFX slightly above the picker cover's base position
	vfx_instance.position = base_position + Vector3(-0.05, -0.1, -0.30) # Adjust Y offset as needed
	 
	var timer = Timer.new()
	timer.wait_time = 0.2 # Adjust time based on VFX duration
	timer.one_shot = true
	timer.timeout.connect(vfx_instance.queue_free)
	add_child(timer)
	timer.start()
	
	is_collecting = false # don't allow to pick many notes on one press
	
func play_miss():
	GameManager.subtract_points()
	fail_player.play()
	
func _process(_delta):
	if is_pressed:
		set_material_activated()
		translate_trigger(Vector3(0,0.2,0))
	else:
		set_material()
		translate_trigger(Vector3(0,0,0))
		
