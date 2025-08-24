extends Node

@export var click_sound: AudioStream = preload("res://sounds/JDSherbert - Ultimate UI SFX Pack - Select - 1.wav")
@export var buy_sound: AudioStream = preload("res://sounds/Retro PowerUP 23.wav")
@export var punch_sound: AudioStream = preload("res://sounds/Retro Impact Punch 07.wav")
@export var shoot_sound: AudioStream = preload("res://sounds/Retro Blop 18.wav")

var player: AudioStreamPlayer2D

func _ready():
	player = AudioStreamPlayer2D.new()
	add_child(player)

func play_sound(sound: AudioStream):
	if sound == null:
		push_warning("Tried to play a null sound")
		return
	player.stream = sound
	player.play()

# shortcuts
func play_click(): play_sound(click_sound)
func play_buy(): play_sound(buy_sound)
func play_punch(): play_sound(punch_sound)
func play_shoot(): play_sound(shoot_sound)
