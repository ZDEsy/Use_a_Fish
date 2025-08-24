extends Node2D
class_name FishNode

@export var fish_name: String = "Unnamed Fish"
@export var rarity: String = "common" 
@export var damage: int = 1
@export var texture: Texture2D
@export var col: int = 0
@export var row: int = 0
@export var attack_cooldown: float = 0.5
@export var bullet_speed: float = 400.0
@export var bullet_lifetime: float = 3.0

@export var automatic: bool = false          # automatic shooting toggle
@export var spread_degrees: float = 5.0      # bullet spread angle

# 🆕 Right click special ability
@export var has_right_click: bool = false
@export var right_click_cooldown: float = 2.0
var _can_right_click: bool = true

@onready var sprite: Sprite2D = $Sprite2D
static var FRAME_SIZE: Vector2 = Vector2(32, 32)
var _can_attack: bool = true
var _holding_fire: bool = false

func get_metadata() -> Dictionary:
	return {
		"fish_name": fish_name,
		"rarity": rarity,
		"damage": damage,
		"col": col,
		"row": row,
		"bullet_speed": bullet_speed
	}

func setup_fish() -> void:
	set_texture_by_cell(col, row)

func _apply_texture(tex: Texture2D) -> void:
	if sprite:
		sprite.texture = tex

func set_texture_by_cell(col: int, row: int) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/fishes.png")
	atlas.region = Rect2(Vector2(col * FRAME_SIZE.x, row * FRAME_SIZE.y), FRAME_SIZE)
	texture = atlas
	_apply_texture(atlas)

# --- NORMAL ATTACK ---
func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position

	# Apply spread
	var spread_rad = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	bullet.direction = direction.rotated(spread_rad)

	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.lifetime = bullet_lifetime

	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	_can_attack = false
	await owner.get_tree().create_timer(attack_cooldown).timeout
	print("time out")
	_can_attack = true


# --- 🆕 SPECIAL RIGHT-CLICK ABILITY ---
func right_click_effect(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not has_right_click or not _can_right_click:
		return

	# ✨ Example default effect: quick dash in the direction of mouse
	if owner:
		var dash_distance := 100.0
		owner.global_position += direction.normalized() * dash_distance

	# cooldown
	_can_right_click = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(right_click_cooldown).timeout
		_can_right_click = true
	else:
		_can_right_click = true


# --- For automatic fire ---
func set_holding_fire(holding: bool) -> void:
	if automatic:
		_holding_fire = holding

func process_automatic_fire(global_pos: Vector2, global_mouse_position: Vector2, owner) -> void:
	if automatic and _holding_fire and _can_attack:
		var mouse_pos = global_mouse_position
		var direction = (mouse_pos - global_pos).normalized()
		if(_can_attack): SoundManager.play_shoot()
		attack(global_pos, direction, owner)
