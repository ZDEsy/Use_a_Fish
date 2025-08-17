extends Control

@onready var items_container: VBoxContainer = $ScrollContainer/VBoxContainer
@export var shop_item_scene: PackedScene  # assign ShopItem.tscn here

func _ready() -> void:
	var icon = preload("res://assets/player/hook.png")
	var icon2 = preload("res://assets/player/hook.png")
	var icon3 = preload("res://assets/player/hook.png")
	var icon4 = preload("res://assets/player/hook.png")
	var icon5 = preload("res://assets/player/hook.png")
	var icon6 = preload("res://assets/player/hook.png")
	
	add_shop_item("+ WALK SPEED", 100, icon)
	add_shop_item("- BITE TIME", 100, icon2)
	add_shop_item("+ BETTER FISH", 100, icon3)
	add_shop_item("- CATCHING DIFFICULTY", 100, icon4)
	add_shop_item("+ DAMAGE", 100, icon5)
	add_shop_item("+ SELL PRICE", 100, icon6)

func add_shop_item(name: String, price: int, icon: Texture2D):
	var item = shop_item_scene.instantiate()
	item.item_name = name
	item.price = price
	item.icon_texture = icon
	item.connect("bought", Callable(self, "_on_item_bought"))
	items_container.add_child(item)

func _on_item_bought(item_name, price):
	print("Bought:", item_name, "for", price)
	# Here you can deduct currency, give upgrades, etc.
