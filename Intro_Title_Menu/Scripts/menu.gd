extends Control
@onready var animPlayer = $genericAnimation

var active_tweens: Dictionary = {}
@export var focus_stretch_ratio: float = 2.5
@export var default_stretch_ratio: float = 1.0
@export var focus_tween_duration: float = 0.2 # Duration in seconds for the tween
@export var focus_tween_transition: Tween.TransitionType = Tween.TRANS_QUINT # Smoother transition
@export var focus_tween_ease: Tween.EaseType = Tween.EASE_OUT # Ease out for entering, ease in for exiting

var buttons: Array[TextureButton] = []
var focused_index: int = -1

var songs_list: Array[Dictionary] = [
	{
		"id": "LP_easy",
		"audio": "res://audiotracks/linkinpark.ogg",
		"map": "res://audiotracks/linkinparkeasy/linkinparkeasy.mboy",
		"cover": "res://Intro_Title_Menu/Images for Menu/LinkinPark.jpg",
		"title": "What I've done",
		"artist": "Linkin Park",
		"accelerate": 1
	},
	{
		"id": "LP_normal",
		"audio": "res://audiotracks/linkinpark.ogg",
		"map": "res://audiotracks/linkinpark2.mboy",
		"cover": "res://Intro_Title_Menu/Images for Menu/LinkinPark.jpg",
		"title": "What I've done",
		"artist": "Linkin Park",
		"accelerate": 2
	},
	{
		"id": "TWICE",
		"audio": "res://audiotracks/twice/what_is_love.mp3",
		"map": "res://audiotracks/twice/TWICE.mboy",
		"cover": "res://Intro_Title_Menu/Images for Menu/twice.jpg",
		"title": "What is love?",
		"artist": "Twice",
		"accelerate": 1
	},
	{
		"id": "NOBODYONE",
		"audio": "res://audiotracks/nobodyone/heroin/nobodyone-Heroin.mp3",
		"map": "res://audiotracks/nobodyone/heroin/nobodyone-Heroin_Multi.mboy",
		"cover": "res://Intro_Title_Menu/Images for Menu/nobodyone.png",
		"title": "Hero In",
		"artist": "Nobody.ONE",
		"accelerate": 1.8
	}
]

func _ready() -> void:
	animPlayer.show_blackBG()
	animPlayer.play_white_fade_in()
	animPlayer.play_menu_screen()
	
	buttons = [
		$%ButtonEasy,
		$%Button1,
		$%Button2,
		$%Button3
	]
	
	$%Button3.grab_focus() # focus first song in the list
	
	for i in range(buttons.size()):
		buttons[i].focus_entered.connect(_on_any_button_focus_entered.bind(buttons[i]))
		buttons[i].focus_exited.connect(_on_any_button_focus_exited.bind(buttons[i]))
		buttons[i].pressed.connect(on_any_button_pressed.bind(buttons[i]))
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):		
		if Input.is_action_just_pressed("ui_down"):
			focused_index = (focused_index + 1) % buttons.size()
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
	
func on_any_button_pressed(button) -> void:
	animPlayer.play_white_fade_out()
	animPlayer.play_press()
	await get_tree().create_timer(0.5).timeout
	GameManager.current_song = songs_list[focused_index]
	get_tree().change_scene_to_file("res://game.tscn")
	
	
