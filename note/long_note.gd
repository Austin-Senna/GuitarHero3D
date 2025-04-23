extends "res://note/base_note.gd"
var curr_length_in_m
var hold_started = false
var hold_canceled = false
var captured = false
var beam_node  # New variable to store our beam reference

func on_ready():
	super.on_ready()
	
	# Calculate beam length
	curr_length_in_m = min(max(100, length - 100) * length_scale, 4.0)
	
	# Remove the original Beam if it exists
	if has_node("Beam"):
		$Beam.queue_free()
	
	# Create a new beam from scratch
	var new_beam = Node3D.new()
	new_beam.name = "BeamNode"
	var beam_mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	
	# Configure the cylinder
	cylinder.top_radius = 0.4
	cylinder.bottom_radius = 0.4
	cylinder.height = curr_length_in_m
	cylinder.radial_segments = 8
	
	# Set up mesh instance
	beam_mesh.mesh = cylinder
	
	# Create a new material
	var mat = StandardMaterial3D.new()
	match line:
		1: mat.albedo_color = Color(0, 1, 0)  # Green
		2: mat.albedo_color = Color(1, 0.5, 0)  # Orange
		3: mat.albedo_color = Color(1, 0.4, 0.7)  # Pink
		4: mat.albedo_color = Color(0, 0, 1)  # Blue
	
	beam_mesh.material_override = mat
	
	# Position correctly
	beam_mesh.rotation_degrees = Vector3(90, 0, 0)  # Rotate to align with Z axis
	beam_mesh.position = Vector3(0, 0, -cylinder.height/2)
	
	# Add to scene
	new_beam.add_child(beam_mesh)
	add_child(new_beam)
	
	# Store reference and start invisible
	beam_node = new_beam
	beam_node.visible = false

func on_process(delta):
	super.on_process(delta)
	
	if not is_collected:
		if is_colliding and picker and not hold_canceled:
			if picker.is_collecting:
				hold_started = true
				# Only make beam visible when holding starts
				if beam_node:
					beam_node.visible = true
			elif hold_started:
				hold_canceled = true
				collect()
		
		if hold_started and not hold_canceled:
			curr_length_in_m -= speed.z * delta
			
			if curr_length_in_m <= 0:
				collect()
			else:
				# Update beam length
				if beam_node:
					var mesh_instance = beam_node.get_child(0)
					if mesh_instance and mesh_instance.mesh:
						mesh_instance.mesh.height = curr_length_in_m
						mesh_instance.position.z = -curr_length_in_m/2
				
				translate(Vector3(0, 0, -speed.z * delta))

func hide_with_beam():
	visible = false
	if beam_node:
		beam_node.visible = false

func collect():
	is_collected = true
	if picker:
		picker.is_collecting = false
	hide_with_beam()
