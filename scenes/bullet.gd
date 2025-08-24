extends Node2D

class_name Bullet

@export var speed: float = 400
@export var rotation_speed: float = 5.0 # radians per second
var direction: Vector2
@export var damage: int = 25
@export var lifetime: float = 3.0
@onready var flash: GPUParticles2D = $GPUParticles2D


@onready var timer: Timer = $Timer

func _physics_process(delta):
	position += direction * speed * delta
	rotation += rotation_speed * delta  # rotate while flying

func _ready():
	timer.wait_time = lifetime
	timer.start()
	
	flash.scale = Vector2(2.0, 2.0)
	flash.global_position = global_position
	flash.rotation = direction.angle()

	# Play particles
	flash.emitting = true

	# Clean up after it finishes
	get_tree().create_timer(0.3).timeout.connect(flash.queue_free)

func get_damage() -> int:
	return damage

func on_hit(target: Node) -> void:
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
