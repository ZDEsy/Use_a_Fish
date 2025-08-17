extends Enemy


func _ready():
	anim_controller.animations = {
		"idle": "idle",
		"run": "run",
		"attack": "attack",
		"die": "die"
	}
	super._ready()
