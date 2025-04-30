# generic_animations.gd
extends Control

# Get a reference to the AnimationPlayer. Adjust path if it's not a direct child.
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player = $AudioPlayer
@onready var bg_player = $BackgroundPlayer
@onready var root_path : NodePath

var audio_pressed = preload("res://Intro_Title_Menu/Audio/press.ogg")
var audio_selected = preload("res://Intro_Title_Menu/Audio/select.ogg")
var audio_game_start = preload("res://Intro_Title_Menu/Audio/game_start.mp3")
var audio_victory = preload("res://Intro_Title_Menu/Audio/victory.mp3")
var audio_title = preload("res://Intro_Title_Menu/Audio/transformers_theme.mp3")
var audio_menu = preload("res://Intro_Title_Menu/Audio/menu_rock.mp3")

func _ready():
	self.z_index = 10;

func show_blackBG():
	$BlackBG.show()
	
func play_white_fade_out():
	$WhiteBlinks.show()
	animation_player.play("white_fade_out")

func play_white_fade_in():
	$WhiteBlinks.show()
	animation_player.play("white_fade_in")

func play_fade_in():
	$Fade.show()
	animation_player.play("black_in")

func play_fade_out():
	animation_player.play("black_out")
	
func play_press():
	audio_player.stream = audio_pressed
	audio_player.play()

func play_select():
	audio_player.stream = audio_selected
	audio_player.play()
	
func play_game_start():
	bg_player.stream = audio_game_start
	bg_player.play()

func play_victory():
	audio_player.stream = audio_victory
	audio_player.play()

func play_title_screen():
	bg_player.stream = audio_title
	bg_player.play()

func play_menu_screen():
	bg_player.stream = audio_menu
	bg_player.play()
