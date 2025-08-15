extends Node2D

@export var speed: float = 400
var direction: Vector2
@export var damage: int = 25
@export var lifetime: float = 3.0

@onready var timer: Timer = $Timer

func _physics_process(delta):
	position += direction * speed * delta

func _ready():
	$Timer.wait_time = lifetime
	$Timer.start()

func get_damage() -> int:
	return damage

func on_hit(target: Node) -> void:
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
