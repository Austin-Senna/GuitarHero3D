# generic_animations.gd
extends Control

# Get a reference to the AnimationPlayer. Adjust path if it's not a direct child.
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var parent = get_tree()
var white_blinds_dur = 0.3 

func _ready():
	self.z_index = 10;

func play_white_blinds():
	$WhiteBlinks.show()
	animation_player.play("white_blinds")

func play_fade_in():
	$Fade.show()
	animation_player.play("black_in")

func play_fade_out():
	animation_player.play("black_out")

# More generic function if you prefer calling by name directly
func play_anim(animation_name: StringName):
	animation_player.play(animation_name)
	
