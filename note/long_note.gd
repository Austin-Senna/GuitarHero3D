extends "res://note/base_note.gd"
var curr_length_in_m
var hold_started = false
var hold_canceled = false
var captured = false
@onready var transformer_font = preload("res://Intro_Title_Menu/Fonts/Transformers Movie.ttf")

var end_block # Reference to the end block
var hold_duration = 0.0 # Track how long the note was held

@onready var bonus_label = Label3D.new()

func on_ready():
	super.on_ready()

	# Use the existing Beam node instead of creating a new one
	curr_length_in_m = (length - 100) * length_scale

	# Just modify the existing beam's scale
	$Beam.scale.z = curr_length_in_m
	# Use call_deferred to set visibility in the next frame
	call_deferred("show_beam")

	# Set the beam's material
	$Beam.set_material(line)

	# Create the end block
	create_end_block()

	# Add bonus label for visual feedback
	bonus_label.position = Vector3(0, 1, 0) # Above the note
	bonus_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bonus_label.text = ""
	bonus_label.visible = false
	bonus_label.font = transformer_font
	add_child(bonus_label)

func show_beam():
	$Beam.visible = true

func create_end_block():
	# Create a copy of the main note's mesh for the end block
	end_block = Node3D.new()
	end_block.name = "EndBlock"

	var end_mesh = MeshInstance3D.new()
	end_mesh.mesh = $AutobotEmblem/AutobotEmblem.mesh.duplicate() # Copy the main note's mesh

	# Match the original mesh scale (0.5, 0.5, 0.5)
	end_mesh.scale = Vector3(0.22,0.22,0.22) # Copy the original scale

	# Create a lighter/emissive material for the end block
	var mat = StandardMaterial3D.new()
	match line:
		1: # Green - #33f928 brightened
			mat.albedo_color = Color(0.4, 1.0, 0.3)
		2: # Orange/Red - #df4200 brightened
			mat.albedo_color = Color(1.0, 0.4, 0.1)
		3: # Pink - #ac30ac brightened
			mat.albedo_color = Color(0.8, 0.3, 0.8)
		4: # Blue - #060aff brightened
			mat.albedo_color = Color(0.2, 0.2, 1.0)

	# Make it slightly emissive for a shiny effect
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mat.emission_energy = 0.4

	end_mesh.material_override = mat
	end_block.add_child(end_mesh)

	# Position at the end of the beam
	end_block.position = Vector3(0, 0, -curr_length_in_m)
	end_block.visible = false # Start invisible

	add_child(end_block)

func on_process(delta):
	super.on_process(delta)

	if not is_collected:
		if is_colliding and picker and not hold_canceled:
			if picker.is_collecting:
				if not hold_started:
					hold_started = true
					hold_duration = 0.0 # Reset hold duration
				# Only make end block visible when holding starts
				if end_block:
					end_block.visible = true
			elif hold_started:
				hold_canceled = true
				collect()

		if hold_started and not hold_canceled:
			hold_duration += delta # Track how long we've been holding

			# Update bonus display (ADD THIS SECTION)
			var current_bonus = GameManager.points_long_note_per_second * hold_duration
			bonus_label.text = "+" + str(int(current_bonus))
			bonus_label.font = transformer_font
			bonus_label.visible = true

			curr_length_in_m -= speed.z * delta

			# Check if we've reached the end block
			if curr_length_in_m <= 0.1: # Small threshold for reaching the end
				collect()
			else:
				# Update beam length
				$Beam.scale.z = curr_length_in_m

				# Move the main note
				translate(Vector3(0, 0, -speed.z * delta))

				# Update end block position to stay at the end of the beam
				end_block.position = Vector3(0, 0, -curr_length_in_m)

func hide_with_beam():
	visible = false
	$Beam.visible = false
	if end_block:
		end_block.visible = false
	bonus_label.visible = false

func collect():
	is_collected = true
	# Award points based on how long the note was held
	GameManager.add_points_long_note(hold_duration)
	if picker:
		picker.is_collecting = false
	hide_with_beam()

# Override the _on_area_exited function to handle long notes
func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("picker"):
		# If we're exiting the picker area and haven't started holding, we missed the note
		if not is_collected and not hold_started:
			GameManager.subtract_points_missed_note()

		is_colliding = false
		picker = area.get_parent()
