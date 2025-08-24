extends Node2D

@onready var score_number_label: Label = $ScoreNumberLabel
@onready var passive_sprite: Sprite2D = $FishSprite
@onready var wave_number_label: Label = $waveNumberLabel
@onready var wave_label: Label = $waveLabel
@onready var health: Node2D = $"../Health"

func _process(delta: float) -> void:
	score_number_label.text = str(GameData.score)
	health.label.text = str(GameData.health)
	wave_number_label.text = str(GameData.wave_count) + "/10"
