extends Node2D

const CAMERA_LEAD: float = 300.0
const CAMERA_Y_SPEED: float = 250.0
const DEAD_ZONE_Y_RATIO: float = 0.32

@onready var _camera: Camera2D = $Camera2D
@onready var _player: Player = $Player

var _dead_zone_half: float
var _spawn_manager  # SpawnManager — tipo resuelto por Godot al cargar el proyecto
var _debug_panel: PanelContainer
var _debug_label: Label

func _ready() -> void:
	_dead_zone_half = get_viewport().get_visible_rect().size.y * DEAD_ZONE_Y_RATIO * 0.5
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_camera.global_position.y = _player.global_position.y
	_player.player_died.connect(_on_player_died)
	_setup_spawn_manager()
	if GameManager.DEBUG_MODE:
		_setup_debug_overlay()

func _process(delta: float) -> void:
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_update_camera_y(delta)
	if GameManager.DEBUG_MODE and _debug_panel != null and _debug_panel.visible:
		_refresh_debug_label()

func _update_camera_y(delta: float) -> void:
	var player_y: float = _player.global_position.y
	var cam_y: float = _camera.global_position.y

	if player_y < cam_y - _dead_zone_half:
		cam_y = move_toward(cam_y, player_y + _dead_zone_half, CAMERA_Y_SPEED * delta)
	elif player_y > cam_y + _dead_zone_half:
		cam_y = move_toward(cam_y, player_y - _dead_zone_half, CAMERA_Y_SPEED * delta)

	_camera.global_position.y = maxf(cam_y, 0.0)

func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.DEBUG_MODE:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.physical_keycode:
		KEY_D:
			_player.distance_meters += GameManager.BIOME_DURATION_METERS
			GameManager.update_distance(_player.distance_meters)
		KEY_R:
			_debug_panel.visible = not _debug_panel.visible

func _on_player_died(distance: float) -> void:
	GameManager.end_game(distance)

func _setup_spawn_manager() -> void:
	_spawn_manager = SpawnManager.new()
	add_child(_spawn_manager)
	_spawn_manager.setup(_camera)

func _setup_debug_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	_debug_panel = PanelContainer.new()
	_debug_panel.position = Vector2(8.0, 8.0)
	_debug_panel.visible = false
	layer.add_child(_debug_panel)

	_debug_label = Label.new()
	_debug_label.add_theme_color_override("font_color", Color.YELLOW_GREEN)
	_debug_panel.add_child(_debug_label)

func _refresh_debug_label() -> void:
	_debug_label.text = (
		"[DEBUG]  D = +1000 m  |  R = ocultar\n"
		+ "Bioma %d — %s\n" % [GameManager.current_biome + 1, GameManager.get_biome_name()]
		+ "Distancia: %.0f m\n" % _player.distance_meters
		+ "Velocidad: %.0f px/s\n" % GameManager.get_speed()
		+ "Ciclo: %d" % GameManager.cycle
	)
