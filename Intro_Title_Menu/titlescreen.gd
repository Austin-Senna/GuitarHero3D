extends Control

var buttons: Array[Button] = []
var focused_index: int = -1

func _ready() -> void:
	buttons = [$StartButton, $ExitButton]  # Add your button nodes here

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		focused_index = (focused_index + 1) % buttons.size()
		buttons[focused_index].grab_focus()
	elif Input.is_action_just_pressed("ui_up"):
		focused_index = (focused_index - 1 + buttons.size()) % buttons.size()
		buttons[focused_index].grab_focus()

func _on_start_button_focus_entered() -> void:
	print("Start button focused")

func _on_exit_button_focus_entered() -> void:
	print("Exit button focused")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Intro_Title_Menu/menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
