extends Control

@onready var items_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var coin_label: Label = $CoinLabel
@export var shop_item_scene: PackedScene

func _ready():
	var hook_icon = preload("res://assets/player/hook.png")

	var shop_items = [
		{
			"name": "+ WALK SPEED",
			"price": 50,
			"stat": "walk_speed",
			"amount": 15.0,
			"icon": hook_icon,
			# Custom price: increase by 30 each buy
			"next_price_func": func(price, count): return price + 30,
			# Custom amount: decrease by 0.2 each buy
			"next_amount_func": func(amount, count): return max(amount - 0.5, 0.1)
		},
		{
			"name": "- BITE TIME",
			"price": 50,
			"stat": "bite_time",
			"amount": -2,
			"icon": hook_icon,
			"next_price_func": func(price, count): return price + 30,
			"next_amount_func": func(amount, count): return min(amount + 0.2, -0.3)
		},
		{
			"name": "+ CATCH SPEED",
			"price": 50,
			"stat": "catching_speed",
			"amount": +3,
			"icon": hook_icon,
			"next_price_func": func(price, count): return price + 30,
			"next_amount_func": func(amount, count): return max(amount - 0.1, 0.2)
		},
		{
			"name": "+ HEALTH",
			"price": 50,
			"stat": "health",
			"amount": 5,
			"icon": hook_icon,
			"next_price_func": func(price, count): return price + 30,
			"next_amount_func": func(amount, count): return max(amount - 0.5, 1)
		},
		{
			"name": "- ENEMY SPEED",
			"price": 50,
			"stat": "enemy_speed",
			"amount": -0.1,
			"icon": hook_icon,
			"next_price_func": func(price, count): return price + 30,
			"next_amount_func": func(amount, count): return min(amount + 0.01, -0.01)
		},
		{
			"name": "- ENEMY DAMAGE",
			"price": 50,
			"stat": "enemy_damage",
			"amount": -0.1,
			"icon": hook_icon,
			"next_price_func": func(price, count): return price + 30,
			"next_amount_func": func(amount, count): return min(amount + 0.01, -0.01)
		},
		{
			"name": "- ENEMY SPAWN",
			"price": 50,
			"stat": "enemy_spawn_rate",
			"amount": -0.1,
			"icon": hook_icon,
			"next_price_func": func(price, count): return price + 30,
			"next_amount_func": func(amount, count): return min(amount + 0.01, -0.01)
		},
		{
			"name": "+ FISH DAMAGE",
			"price": 50,
			"stat": "fish_damage",
			"amount": +5,
			"icon": hook_icon,
			"next_price_func": func(price, count): return price + 30,
			"next_amount_func": func(amount, count): return max(amount - 1, 1)
		},
	]

	for item_data in shop_items:
		var item = shop_item_scene.instantiate()
		item.item_name = item_data["name"]
		item.base_price = item_data["price"]
		item.icon_texture = item_data["icon"]
		item.stat_name = item_data["stat"]
		item.base_amount = item_data["amount"]
		item.next_price_func = item_data.get("next_price_func", null)
		item.next_amount_func = item_data.get("next_amount_func", null)
		item.connect("bought", Callable(self, "_on_item_bought"))
		items_container.add_child(item)

func _on_item_bought(stat_name: String, price: int, amount: float):
	if GameData.upgrade_stat(stat_name, price, amount):
		print("Upgraded", stat_name, "by", amount, "→ New value:", GameData.get(stat_name))
		_update_coin_label()
		SoundManager.play_buy()
	else:
		print("Not enough coins to upgrade", stat_name)

func _update_coin_label() -> void:
	coin_label.text = str(GameData.coins)
