extends Node

var anim: AnimatedSprite2D
var animations: Dictionary = {} # { "idle": "idle", "run": "run", "attack": "atk", ... }

func _ready():
	if not anim:
		anim = get_parent().get_node("AnimatedSprite2D")

func play(key: String) -> void:
	if(animations.has(key)):
		anim.play(animations[key])

func has_animation(key: String) -> bool:
	return animations.has(key) and anim.sprite_frames.has_animation(animations[key])
