extends Control

signal bought(item_name: String, price: int)

@export var item_name: String
@export var price: int
@export var icon_texture: Texture2D

@onready var name_label: Label = $NameLabel
@onready var price_label: Label = $PriceLabel
@onready var icon: TextureRect = $Icon
@onready var buy_button: Button = $BuyButton

func _ready():
	name_label.text = item_name
	price_label.text = str(price)
	icon.texture = icon_texture
	buy_button.connect("pressed", Callable(self, "_on_buy_pressed"))

func _on_buy_pressed():
	emit_signal("bought", item_name, price)
