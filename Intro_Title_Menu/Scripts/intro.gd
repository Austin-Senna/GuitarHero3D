extends Control

@onready var generic_anim_player: Control = $genericAnimation
var title = preload("res://Intro_Title_Menu/title.tscn")

func _ready():
	generic_anim_player.play_game_start()
	generic_anim_player.play_fade_in()
	get_tree().create_timer(2).timeout.connect(blackout)
	
func blackout():
	generic_anim_player.play_fade_out()
	get_tree().create_timer(2).timeout.connect(startmenu)
	
func startmenu():
	get_tree().change_scene_to_packed(title)
