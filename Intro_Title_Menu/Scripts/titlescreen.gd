extends Control

var buttons: Array[TextureButton] = []
var focused_index: int = -1
@onready var animPlayer = $genericAnimation

var active_tweens: Dictionary = {}
@export var focus_stretch_ratio: float = 2.5
@export var default_stretch_ratio: float = 1.0
@export var focus_tween_duration: float = 0.2 # Duration in seconds for the tween
@export var focus_tween_transition: Tween.TransitionType = Tween.TRANS_QUINT # Smoother transition
@export var focus_tween_ease: Tween.EaseType = Tween.EASE_OUT # Ease out for entering, ease in for exiting


func _ready() -> void:
	animPlayer.play_fade_in()
	animPlayer.play_victory()
	get_tree().create_timer(1.25).timeout.connect(animPlayer.play_title_screen)

	buttons = [
		$%StartButton,
		$%ExitButton
	]
	
	for i in range(buttons.size()):
		buttons[i].focus_entered.connect(_on_any_button_focus_entered.bind(buttons[i]))
		buttons[i].focus_exited.connect(_on_any_button_focus_exited.bind(buttons[i]))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		focused_index = (focused_index + 1) % buttons.size()
		buttons[focused_index].grab_focus()
		animPlayer.play_select()
		
	elif Input.is_action_just_pressed("ui_up"):
		focused_index = (focused_index - 1 + buttons.size()) % buttons.size()
		buttons[focused_index].grab_focus()
		animPlayer.play_select()
		
func _on_any_button_focus_entered(button) -> void:
	var parent_node = button.get_parent()
	if active_tweens.has(parent_node):
		active_tweens[parent_node].kill()
	var tween = create_tween()
	active_tweens[parent_node] = tween
	tween.tween_property(parent_node, "size_flags_stretch_ratio", focus_stretch_ratio, focus_tween_duration)\
		 .set_trans(focus_tween_transition)\
		 .set_ease(focus_tween_ease) # Use EASE_OUT for expanding

func _on_any_button_focus_exited(button) -> void:
	var parent_node = button.get_parent()
	if active_tweens.has(parent_node):
		active_tweens[parent_node].kill()
	var tween = create_tween()
	active_tweens[parent_node] = tween
	tween.tween_property(parent_node, "size_flags_stretch_ratio", default_stretch_ratio, focus_tween_duration)\
		 .set_trans(focus_tween_transition)\
		 .set_ease(focus_tween_ease)

func _on_start_button_pressed() -> void:
	animPlayer.play_white_fade_out()
	animPlayer.play_press()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Intro_Title_Menu/menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
