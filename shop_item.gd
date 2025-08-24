extends Control

signal bought(stat_name: String, price: int, amount: float)

# Basic item properties
@export var item_name: String
@export var base_price: int
@export var icon_texture: Texture2D
@export var stat_name: String
@export var base_amount: float

# Optional custom functions for price and amount scaling
var next_price_func: Callable = Callable(self, "_default_price_func")
var next_amount_func: Callable = Callable(self, "_default_amount_func")

func _default_price_func(price, count):
	return int(base_price * pow(1.5, count))

func _default_amount_func(amount, count):
	return base_amount / (count + 1)

# Internal state
var current_price: int
var current_amount: float
var buy_count: int = 0

@onready var name_label: Label = $NameLabel
@onready var price_label: Label = $PriceLabel
@onready var icon: TextureRect = $Icon
@onready var buy_button: TextureButton = $BuyButton

func _ready():
	current_price = base_price
	current_amount = base_amount
	_update_ui()

func _on_buy_pressed():
	print("Trying to buy")
	if GameData.coins >= current_price:
		# Deduct coins immediately
		GameData.coins -= current_price
		GameData.upgrade_stat(stat_name, current_price, current_amount)

		emit_signal("bought", stat_name, current_price, current_amount)
		buy_count += 1

		# Update price and amount after successful purchase
		if next_price_func:
			current_price = int(next_price_func.call(current_price, buy_count))
		else:
			current_price = int(base_price * pow(1.5, buy_count))

		if next_amount_func:
			current_amount = float(next_amount_func.call(current_amount, buy_count))
		else:
			current_amount = base_amount / (buy_count + 1)

		_update_ui()

		# Update the coin label in all shop panels
		get_tree().call_group("shop_panels", "_update_coin_label")



func _update_ui():
	name_label.text = item_name
	price_label.text = str(current_price)
	icon.texture = icon_texture
