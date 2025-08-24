extends FishNode

@export var shield_bullet_scene: PackedScene
@export var shield_radius: float = 80.0
@export var shield_speed: float = 180.0 # degrees per second
@export var num_bullets: int = 6

var shield_bullets: Array = []
var shield_active: bool = false

func right_click_effect(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not has_right_click or not _can_right_click:
		return
	if not owner or not owner is CharacterBody2D:
		return

	if shield_active:
		# optional: toggle off
		_remove_shield()
	else:
		_spawn_shield(owner)

	# Cooldown
	_can_right_click = false
	if owner.get_tree():
		await owner.get_tree().create_timer(right_click_cooldown).timeout
		_can_right_click = true
	else:
		_can_right_click = true

func _spawn_shield(owner: CharacterBody2D) -> void:
	shield_bullets.clear()
	for i in range(num_bullets):
		var bullet = shield_bullet_scene.instantiate()
		owner.get_parent().add_child(bullet)
		# Initial position around player
		var angle = (i / num_bullets) * TAU
		bullet.global_position = owner.global_position + Vector2(cos(angle), sin(angle)) * shield_radius
		# store custom angle
		bullet.set_meta("orbit_angle", angle)
		bullet.set_meta("owner_node", owner)
		shield_bullets.append(bullet)
	shield_active = true

func _remove_shield():
	for b in shield_bullets:
		if b and b.is_inside_tree():
			b.queue_free()
	shield_bullets.clear()
	shield_active = false

func _process(delta: float) -> void:
	if not shield_active:
		return

	for b in shield_bullets:
		if not b or not b.has_meta("owner_node"):
			continue
		var owner = b.get_meta("owner_node")
		if not owner or not owner.is_inside_tree():
			continue

		# orbit around player
		var angle = b.get_meta("orbit_angle")
		angle += deg_to_rad(shield_speed) * delta
		b.set_meta("orbit_angle", angle)
		b.global_position = owner.global_position + Vector2(cos(angle), sin(angle)) * shield_radius
