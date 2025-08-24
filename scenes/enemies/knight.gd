extends Enemy

func _ready():
	anim_controller.animations = {
		"idle": "idle",
		"run": "run",
		"attack": "attack",
		"die": "die",
	}
	super._ready()


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d.animation == "attack" and (animated_sprite_2d.frame == 5 or animated_sprite_2d.frame == 11 or animated_sprite_2d.frame == 18): # <-- frame where hit connects
		_attack_hit()
