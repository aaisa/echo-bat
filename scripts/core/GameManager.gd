extends Node

enum GameState { PLAYING, GAME_OVER }

const SAVE_PATH: String = "user://record.dat"

var state: GameState = GameState.PLAYING
var last_distance: float = 0.0
var record_distance: float = 0.0

func _ready() -> void:
	_load_record()

func start_game() -> void:
	state = GameState.PLAYING
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func end_game(distance: float) -> void:
	state = GameState.GAME_OVER
	last_distance = distance
	if distance > record_distance:
		record_distance = distance
		_save_record()
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func _save_record() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_float(record_distance)

func _load_record() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		record_distance = file.get_float()
