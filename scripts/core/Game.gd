extends Node2D

const CAMERA_LEAD: float = 300.0
const CAMERA_Y_SPEED: float = 250.0
const DEAD_ZONE_Y_RATIO: float = 0.32

@onready var _camera: Camera2D = $Camera2D
@onready var _player: Player = $Player
@onready var _background: Node2D = $Background

var _dead_zone_half: float
var _spawn_manager  # SpawnManager — tipo resuelto por Godot al cargar el proyecto

func _ready() -> void:
	_dead_zone_half = get_viewport().get_visible_rect().size.y * DEAD_ZONE_Y_RATIO * 0.5
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_camera.global_position.y = _player.global_position.y
	_player.player_died.connect(_on_player_died)
	_setup_spawn_manager()

func _process(delta: float) -> void:
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_update_camera_y(delta)
	_update_background()
	if GameManager.DEBUG_MODE:
		GameManager.debug_update(_player.distance_meters, GameManager.get_speed())

func _update_camera_y(delta: float) -> void:
	var player_y: float = _player.global_position.y
	var cam_y: float = _camera.global_position.y

	if player_y < cam_y - _dead_zone_half:
		cam_y = move_toward(cam_y, player_y + _dead_zone_half, CAMERA_Y_SPEED * delta)
	elif player_y > cam_y + _dead_zone_half:
		cam_y = move_toward(cam_y, player_y - _dead_zone_half, CAMERA_Y_SPEED * delta)

	_camera.global_position.y = maxf(cam_y, 0.0)

func _update_background() -> void:
	# ParallaxBackground necesita scroll_offset para seguir la cámara
	var parallax_bg: ParallaxBackground = _background.get_node("ParallaxBackground")
	if parallax_bg != null:
		parallax_bg.scroll_offset = _camera.global_position

# D solo funciona durante la partida (necesita al jugador)
func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.DEBUG_MODE:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_D:
			_player.distance_meters += GameManager.BIOME_DURATION_METERS
			GameManager.update_distance(_player.distance_meters)

func _on_player_died(distance: float) -> void:
	GameManager.end_game(distance)

func _setup_spawn_manager() -> void:
	_spawn_manager = SpawnManager.new()
	add_child(_spawn_manager)
	_spawn_manager.setup(_camera)
