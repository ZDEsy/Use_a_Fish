extends Area2D

@export var speed: float = 200.0
@export var rotation_speed: float = 10.0  # radians per second (≈57° per second)
var direction: Vector2 = Vector2.ZERO
var damage: int = 10
var shooter: Node = null

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta
		rotation += rotation_speed * delta  # make it spin

	# Optional: free if far away
	if position.length() > 2000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
