extends Enemy

func _ready():
	anim_controller.animations = {
		"run": "run",
		"attack": "attack",
		"die": "die"
	}
	super._ready()
