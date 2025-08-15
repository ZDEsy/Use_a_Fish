extends Node2D
class_name FishNode

@export var fish_name: String = "Unnamed Fish"
@export var rarity: String = "common" 
@export var difficulty: int = 1 
@export var damage: int = 1
@export var ammo: int = 0    
@export var weight: float = 0.0 
@export var texture: Texture2D
@export var col: int = 0
@export var row: int = 0
@onready var sprite: Sprite2D = $Sprite2D
static var FRAME_SIZE: Vector2 = Vector2(32, 32)

func get_metadata() -> Dictionary:
	return {
		"fish_name": fish_name,
		"rarity": rarity,
		"difficulty": difficulty,
		"damage": damage,
		"ammo": ammo,
		"weight": weight,
		"col": col,
		"row": row
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

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if ammo == 0:
		return
	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position
	bullet.direction = direction
	bullet.damage = damage
	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)
	if ammo > 0:
		ammo -= 1
