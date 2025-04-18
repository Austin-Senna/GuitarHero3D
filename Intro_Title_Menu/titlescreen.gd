extends Control

var buttons: Array[TextureButton] = []
var focused_index: int = -1
@onready var animPlayer = $genericAnimation

func _ready() -> void:
	animPlayer.play_fade_in()
	buttons = [
		$%StartButton,
		$%ExitButton
	]

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
	animPlayer.play_white_blinds()
	await get_tree().create_timer(animPlayer.white_blinds_dur).timeout
	get_tree().change_scene_to_file("res://Intro_Title_Menu/menu.tscn")

func _on_exit_button_pressed() -> void:
	animPlayer.play_white_blinds()
	get_tree().quit()
