extends FishNode

var burst_index: int = 1 # tracks 1,2,3
var burst_delay: float = 0.1 # delay between bursts
var bullet_angle_offset: float = 10 # degrees between bullets in a burst

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	_can_attack = false
	shoot_burst(position, direction, owner)

	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true


func shoot_burst(position: Vector2, direction: Vector2, owner: Node) -> void:
	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# Number of bullets in this burst
	var bullets_in_burst = burst_index

	# Calculate starting angle so bullets are centered around 'direction'
	var total_angle = (bullets_in_burst - 1) * bullet_angle_offset
	var start_angle = -total_angle / 2.0

	for i in range(bullets_in_burst):

		var bullet = bullet_scene.instantiate()
		bullet.global_position = position
		bullet.direction = direction.rotated(deg_to_rad(start_angle + i * bullet_angle_offset))
		bullet.damage = damage
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime

		if owner and owner.get_parent():
			owner.get_parent().add_child(bullet)

	# Prepare next burst
	burst_index += 1
	if burst_index > 3:
		burst_index = 1

	# Optional: small delay between bursts if calling repeatedly
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(burst_delay).timeout
