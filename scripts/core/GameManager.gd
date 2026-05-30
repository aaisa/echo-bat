extends Node

enum GameState { PLAYING, GAME_OVER }

const SAVE_PATH: String = "user://record.dat"

const BIOME_DATA: Array = [
	{name = "La Entrada",  gap = 210.0, spacing = 400.0},
	{name = "La Penumbra", gap = 190.0, spacing = 380.0},
	{name = "La Catarata", gap = 170.0, spacing = 360.0},
	{name = "Las Agujas",  gap = 150.0, spacing = 340.0},
	{name = "El Núcleo",   gap = 130.0, spacing = 320.0},
]
const BIOME_DURATION_METERS: float = 1000.0
const BASE_SPEED: float = 400.0
const MAX_SPEED: float = 550.0
const CYCLE_SPEED_BONUS: float = 0.10

var state: GameState = GameState.PLAYING
var last_distance: float = 0.0
var last_biome_name: String = ""
var record_distance: float = 0.0
var current_biome: int = 0
var cycle: int = 1

func _ready() -> void:
	_load_record()

func start_game() -> void:
	state = GameState.PLAYING
	current_biome = 0
	cycle = 1
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func end_game(distance: float) -> void:
	state = GameState.GAME_OVER
	last_distance = distance
	last_biome_name = get_biome_name()
	if distance > record_distance:
		record_distance = distance
		_save_record()
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

# Llamado cada frame desde Player._physics_process para mantener el bioma actualizado
func update_distance(distance: float) -> void:
	var total_biome_index: int = int(distance / BIOME_DURATION_METERS)
	current_biome = total_biome_index % 5
	var new_cycle: int = int(float(total_biome_index) / 5.0) + 1
	if new_cycle > cycle:
		cycle = new_cycle

func get_biome_params() -> Dictionary:
	return BIOME_DATA[current_biome]

func get_biome_name() -> String:
	return BIOME_DATA[current_biome].name

func get_speed() -> float:
	return minf(BASE_SPEED * pow(1.0 + CYCLE_SPEED_BONUS, cycle - 1), MAX_SPEED)

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
