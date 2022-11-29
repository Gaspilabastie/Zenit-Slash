extends Node

onready var progressBar = $ProgressBar

export(int) var max_health = 100 setget set_max
onready var health = max_health setget set_health

func set_health(new_value):
	health = new_value
	health = clamp(health, 0, max_health)
	progressBar.value = health

func set_max(new_value):
	max_health = new_value
	max_health = max(1, new_value)

func _on_Player_health_updated(value):
	set_health(value)
