extends Node2D
class_name Fish

@export var rarity: String
@export var difficulty: int
@export var damage: int
@export var ammo : int
@export var texture: Texture2D

static var FRAME_SIZE: Vector2 = Vector2(32, 32)          # one sprite size
static var COLUMNS: int = 12

@onready var sprite: Sprite2D = $Sprite2D
#func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	#if ammo == 0:
		#return
	#var bullet_scene := preload("res://scenes/Bullet.tscn")
	#var bullet = bullet_scene.instantiate()
	#bullet.global_position = position
	#bullet.direction = direction
	#bullet.damage = damage
	#get_tree().get_root().add_child(bullet)
	#if ammo > 0:
		#ammo -= 1

func _ready() -> void:
	# if texture was set before instancing, apply it to the Sprite2D
	if texture:
		_apply_texture(texture)

func _apply_texture(tex: Texture2D) -> void:
	if sprite:
		sprite.texture = tex

func set_texture_by_cell(col: int, row: int) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/fishes.png")
	atlas.region = Rect2(Vector2(col * FRAME_SIZE.x, row * FRAME_SIZE.y), FRAME_SIZE)
	texture = atlas
	_apply_texture(atlas)
