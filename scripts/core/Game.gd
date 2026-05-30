extends Node2D

const CAMERA_LEAD: float = 300.0
const CAMERA_Y_SPEED: float = 250.0
const DEAD_ZONE_Y_RATIO: float = 0.32

@onready var _camera: Camera2D = $Camera2D
@onready var _player: Player = $Player

var _dead_zone_half: float

func _ready() -> void:
	_dead_zone_half = get_viewport().get_visible_rect().size.y * DEAD_ZONE_Y_RATIO * 0.5
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_camera.global_position.y = _player.global_position.y
	_player.player_died.connect(_on_player_died)
	_spawn_test_obstacles()

func _process(delta: float) -> void:
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_update_camera_y(delta)

func _update_camera_y(delta: float) -> void:
	var player_y: float = _player.global_position.y
	var cam_y: float = _camera.global_position.y

	if player_y < cam_y - _dead_zone_half:
		cam_y = move_toward(cam_y, player_y + _dead_zone_half, CAMERA_Y_SPEED * delta)
	elif player_y > cam_y + _dead_zone_half:
		cam_y = move_toward(cam_y, player_y - _dead_zone_half, CAMERA_Y_SPEED * delta)

	_camera.global_position.y = maxf(cam_y, 0.0)

func _on_player_died(distance: float) -> void:
	GameManager.end_game(distance)

# Pares de estalactitas de prueba con gap de 210 px (3.5 × altura del murciélago).
# Se elimina en Fase 2 cuando BiomeGenerator genere el nivel de forma procedural.
func _spawn_test_obstacles() -> void:
	var pairs := [
		{x = 500.0, gap_center = 350.0},
		{x = 900.0, gap_center = 310.0},
		{x = 1300.0, gap_center = 390.0},
	]
	var gap_half: float = 105.0
	for pair in pairs:
		var x: float = pair.x
		var cy: float = pair.gap_center
		# Estalactita superior: desde el techo (y=0) hasta cy-gap_half
		var top_h: float = cy - gap_half
		_add_obstacle(Vector2(x, top_h * 0.5), Vector2(60.0, top_h))
		# Estalactita inferior: desde cy+gap_half hasta el suelo (y=660)
		var bot_top: float = cy + gap_half
		var bot_h: float = 660.0 - bot_top
		_add_obstacle(Vector2(x, bot_top + bot_h * 0.5), Vector2(60.0, bot_h))

func _add_obstacle(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.add_to_group("obstacle")

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)

	var visual := Polygon2D.new()
	var hw: float = size.x * 0.5
	var hh: float = size.y * 0.5
	visual.polygon = PackedVector2Array([
		Vector2(-hw, -hh), Vector2(hw, -hh),
		Vector2(hw, hh), Vector2(-hw, hh),
	])
	visual.color = Color(0.45, 0.25, 0.1)
	body.add_child(visual)

	add_child(body)
