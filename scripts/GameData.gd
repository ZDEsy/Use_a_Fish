extends Node

# ----------------------
# Player-related upgrades
# ----------------------
var walk_speed: float = 100.0
var catching_speed: float = 15.0
var bite_time: float = 15.0
var health: int = 100

# ----------------------
# Enemy-related upgrades
# ----------------------
var enemy_speed: float = 1.0
var enemy_damage: int = 1.0
var enemy_spawn_rate: float = 1.0  # enemies per X seconds
var wave_set_index: int = 0

# ----------------------
# Fish-related upgrades
# ----------------------
var fish_damage: float = 1.0
var fish_rarity_multiplier: float = 1.0
var better_fish_chance: float = 0.1

# ----------------------
# Scores
# ----------------------
var score: int = 0
var high_score: int = 0
var wave_count: int = 0

# ----------------------
# Economy
# ----------------------
var coins: int = 0

# ----------------------
# Upgrade helpers
# ----------------------
func add_coins(amount: int) -> void:
	coins += amount

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false

# ----------------------
# Saving & Loading
# ----------------------
const SAVE_PATH := "res://savegame.json"

# keep all upgrade keys in one array
const SAVE_KEYS := [
	"high_score",
]

func update_high_score(new_score: int) -> void:
	if new_score > high_score:
		high_score = new_score
		save_game()

func add_score(amount: int) -> void:
	score += amount
	if score > high_score:
		high_score = score
	save_game()

func upgrade_stat(stat_name: String, price: int, amount: float) -> bool:
	if not spend_coins(price):
		return false
	if stat_name in SAVE_KEYS:
		set(stat_name, get(stat_name) + amount)
		save_game()
		return true
	return false


func save_game():
	var data = {}
	for key in SAVE_KEYS:
		data[key] = get(key)   # safe because all keys exist in this script
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return
	for key in SAVE_KEYS:
		if data.has(key):
			set(key, data[key])
