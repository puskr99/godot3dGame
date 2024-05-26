extends Node3D

@onready var bg_music = $BgMusic
@onready var footsteps = $Footsteps

# Called when the node enters the scene tree for the first time.
func _ready():
	play_bg_music()


func play_bg_music() -> void:
	if bg_music.is_playing():
		return
		
	bg_music.play()


func stop_bg_music() -> void:
	if bg_music.is_playing():
		bg_music.stop()


func play_footstep_sound(pitch : float = 1) -> void:
	if footsteps.is_playing():
		return
	
	footsteps.pitch_scale = pitch
	footsteps.play()


func stop_footstep_sound() -> void:
	if footsteps.is_playing():
		footsteps.stop()
