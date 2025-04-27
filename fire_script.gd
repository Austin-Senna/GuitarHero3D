# Example script to control the shader
extends MeshInstance3D

@onready var material: ShaderMaterial = material_override as ShaderMaterial # Or get_surface_override_material(0)

var is_star_power_active = false
var current_activation = 0.0

func _process(delta):
	# Smoothly transition activation level
	var target_activation = 1.0 if is_star_power_active else 0.0
	current_activation = lerp(current_activation, target_activation, delta * 5.0) # Adjust lerp speed (5.0)

	if material:
		material.set_shader_parameter("activation_level", current_activation)

func activate_star_power():
	is_star_power_active = true

func deactivate_star_power():
	is_star_power_active = false

# Example usage:
func _input(event):
	if event.is_action_pressed("toggle_star_power"): # Define this action in Input Map
		if is_star_power_active:
			deactivate_star_power()
		else:
			activate_star_power()
