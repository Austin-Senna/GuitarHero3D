extends Node2D

@onready var animation_intro = $AnimationPlayer
var title = preload("res://Intro_Title_Menu/title.tscn")

func _ready():
	animation_intro.play("black_in")
	get_tree().create_timer(2).timeout.connect(blackout)
	
func blackout():
	animation_intro.play("black_out")
	get_tree().create_timer(2).timeout.connect(startmenu)
	
	
func startmenu():
	get_tree().change_scene_to_packed(title)
