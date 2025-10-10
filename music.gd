extends Node3D

@onready var anim = $AnimationPlayer
@onready var player = $AudioStreamPlayer3D

var speed
var started
var pre_start_duration
var start_time 

var video_time := 0.0
var audio_time := 0.0

func _ready():
	pass
	
func setup(game):
	player.stream = game.audio
	started = false
	speed = game.speed
	pre_start_duration = game.bar_length
	start_time = game.start_time
	
func start():
	started = true
	player.play(start_time)
	#anim.play("sound_on")
	
func _process(delta):
	if not started:
		pre_start_duration -= speed*delta
		if pre_start_duration <= 0:
			start()
			return
	else:
		#TODO: move to road node and sync logic
		video_time += delta
		
		audio_time = player.get_playback_position() + AudioServer.get_time_since_last_mix()
		audio_time -= AudioServer.get_output_latency()
		
		print([video_time, " - ", audio_time])
	
	
