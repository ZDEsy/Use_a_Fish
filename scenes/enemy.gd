extends CharacterBody2D
class_name Enemy

@onready var anim_controller: Node2D = $EnemyAnimationController
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var hit_area: Area2D = $HitArea

@export var health: int = 100
@export var speed: float = 100
@export var damage: int = 10
@export var attack_range: float = 24.0
@export var attack_cooldown: float = 1.0

enum State { IDLE, RUN, ATTACK, HURT, DEAD }
var state: State = State.RUN

var player: Node = null
var _attack_timer: float = 0.0

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0: player = players[0]
	else:
		if get_tree().current_scene.has_node("Player"):
			player = get_tree().current_scene.get_node("Player")
	randomize()
	_update_animation()

func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	health -= amount
	_play_hurt()
	_flash_white()
	if health <= 0:
		die()


func _flash_white():
	var original_modulate = animated_sprite_2d.modulate
	
	# Multiply by white color (full brightness)
	animated_sprite_2d.modulate = Color(5,5,5,5)  # pure white flash
	
	# Wait a short time
	await get_tree().create_timer(0.1).timeout
	
	# Restore original color
	animated_sprite_2d.modulate = original_modulate

func die() -> void:
	state = State.DEAD
	anim_controller.play("die")
	z_index = 0
	anim_controller.z_index = 0

func attack(target: Node) -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(damage)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	if not player:
		print(player)
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance <= attack_range:
		velocity = Vector2.ZERO
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			_play_attack()
			attack(player)
		else:
			if state != State.ATTACK:
				state = State.IDLE
	else:
		state = State.RUN
		var dir = to_player.normalized()
		velocity = dir * speed
		move_and_slide()
		_face_direction(dir)
	
	_update_animation()

func _play_attack() -> void:
	state = State.ATTACK
	anim_controller.play("attack")

func _play_hurt() -> void:
	state = State.HURT
	anim_controller.play("hurt")


func _face_direction(dir: Vector2) -> void:
	if abs(dir.x) > 0.1 and anim_controller.anim:
		anim_controller.anim.flip_h = dir.x < 0

func _update_animation() -> void:
	match state:
		State.IDLE:
			if anim_controller.has_animation("idle"):
				anim_controller.play("idle")
			else:
				anim_controller.play("run") # fallback
		State.RUN:
			anim_controller.play("run")
		State.ATTACK:
			pass
		State.HURT:
			pass
		State.DEAD:
			pass


func _on_hit_area_area_entered(body) -> void:
	if(state == State.DEAD):
		return
	
	var dmg: int = 0
	if body.has_method("get_damage"):
		dmg = int(body.get_damage())
	elif body.has_meta("damage"):
		dmg = int(body.get_meta("damage"))
	elif "damage" in body:
		dmg = int(body.damage)
	if dmg > 0:
		take_damage(dmg)
		if body.has_method("on_hit"):
			body.on_hit(self)
		elif body.is_in_group("bullets"):
			body.queue_free()
	print(health, "--- health")


func _on_animated_sprite_2d_animation_finished(anim_name: String) -> void:
	if anim_name == "die":
		queue_free()
