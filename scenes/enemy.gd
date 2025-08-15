extends CharacterBody2D

class_name Enemy
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea

@export var health: int = 100
@export var speed: float = 100
@export var damage: int = 10
@export var attack_range: float = 24.0
@export var attack_cooldown: float = 1.0

enum State { IDLE, RUN, ATTACK, HURT, DEAD }
var state: State = State.IDLE

var player: Node = null
var _attack_timer: float = 0.0

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		if get_tree().current_scene.has_node("Player"):
			player = get_tree().current_scene.get_node("Player")
	randomize()

func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	health -= amount
	_play_hurt()
	if health <= 0:
		die()

func die() -> void:
	state = State.DEAD
	anim.play("die")

func attack(target: Node) -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(damage)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	if not player:
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance <= attack_range:
		velocity = Vector2.ZERO
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			state = State.ATTACK
			_attack_timer = attack_cooldown
			anim.play("attack")
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

func _face_direction(dir: Vector2) -> void:
	if abs(dir.x) > 0.1:
		anim.flip_h = dir.x < 0

func _update_animation() -> void:
	match state:
		State.IDLE:
			if anim.animation != "run":
				anim.play("run")
		State.RUN:
			if anim.animation != "run":
				anim.play("run")
		State.ATTACK:
			pass
		State.HURT:
			if anim.animation != "hurt":
				anim.play("hurt")
		State.DEAD:
			pass

func _play_hurt() -> void:
	state = State.HURT
	anim.play("hurt")
	anim.animation_finished.connect(func(_name):
		state = State.IDLE)


func _on_hit_area_area_entered(body) -> void:
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


func _on_animated_sprite_2d_animation_finished(anim_name) -> void:
	if anim_name == "die":
		queue_free()
