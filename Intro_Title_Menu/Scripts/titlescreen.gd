extends Control

var buttons: Array[TextureButton] = []
var focused_index: int = -1
@onready var animPlayer = $genericAnimation
var original_scale: Vector2 = Vector2.ONE # Default scale (1.0, 1.0)
var selected_scale: Vector2 = Vector2(1.05,1.05)
var pressed_scale: Vector2 = Vector2(0.9, 0.9) # Scale when pressed (e.g., 90%)

func _ready() -> void:
	animPlayer.play_fade_in()
	animPlayer.play_victory()
	get_tree().create_timer(1.25).timeout.connect(animPlayer.play_title_screen)

	buttons = [
		$%StartButton,
		$%ExitButton
	]
	
	for i in range(buttons.size()):
		var button = buttons[i]
		button.pivot_offset = button.size / 2.0
		button.scale = original_scale


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		focused_index = (focused_index + 1) % buttons.size()
		buttons[focused_index].grab_focus()
		
	elif Input.is_action_just_pressed("ui_up"):
		focused_index = (focused_index - 1 + buttons.size()) % buttons.size()
		buttons[focused_index].grab_focus()
		

func _on_start_button_focus_entered() -> void:
	animPlayer.play_select()
	buttons[0].scale = selected_scale

func _on_start_button_focus_exited() -> void:
	buttons[0].scale = original_scale

func _on_exit_button_focus_entered() -> void:
	animPlayer.play_select()
	buttons[1].scale = selected_scale
	
func _on_exit_button_focus_exited() -> void:
	buttons[1].scale = original_scale

func _on_start_button_pressed() -> void:
	animPlayer.play_white_fade_out()
	animPlayer.play_press()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Intro_Title_Menu/menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
