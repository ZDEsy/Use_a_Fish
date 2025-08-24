extends Node

var music_player: AudioStreamPlayer2D
var fade_tween: Tween
var music_enabled: bool = true  # toggle via checkbox

func _ready():
	# Setup music player
	music_player = AudioStreamPlayer2D.new()
	add_child(music_player)
	music_player.bus = "Music"  # make sure you have a "Music" bus in Audio

func play_music(music: AudioStream, fade_time: float = 1.0):
	if not music_enabled:
		return
	if music_player.stream == music:
		return
	
	# Fade out current track if playing
	if music_player.playing:
		if fade_tween: fade_tween.kill()
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", -40, fade_time)
		await fade_tween.finished
		music_player.stop()

	# Start new track
	music.loop = true  # 🔁 ensure looping
	music_player.stream = music
	music_player.volume_db = -40
	music_player.play()

	# Fade in
	fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_db", 0, fade_time)

func stop_music(fade_time: float = 1.0):
	if not music_player.playing:
		return
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_db", -40, fade_time)
	await fade_tween.finished
	music_player.stop()

# Toggle music on/off
func set_music_enabled(enabled: bool):
	music_enabled = enabled
	if not enabled:
		stop_music(0.5)
