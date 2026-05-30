extends Node2D

# Píxeles que la cámara se adelanta al jugador en el eje X
const CAMERA_LEAD: float = 300.0
# Velocidad de desplazamiento vertical cuando el jugador sale de la zona muerta
const CAMERA_Y_SPEED: float = 250.0
# Fracción del alto de pantalla que define la zona muerta vertical (32% central)
const DEAD_ZONE_Y_RATIO: float = 0.32

@onready var _camera: Camera2D = $Camera2D
@onready var _player: CharacterBody2D = $Player

var _dead_zone_half: float

func _ready() -> void:
	_dead_zone_half = get_viewport().get_visible_rect().size.y * DEAD_ZONE_Y_RATIO * 0.5
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_camera.global_position.y = _player.global_position.y

func _process(delta: float) -> void:
	_camera.global_position.x = _player.global_position.x + CAMERA_LEAD
	_update_camera_y(delta)

func _update_camera_y(delta: float) -> void:
	var player_y: float = _player.global_position.y
	var cam_y: float = _camera.global_position.y

	if player_y < cam_y - _dead_zone_half:
		# Jugador por encima de la zona muerta → cámara sube hacia él
		cam_y = move_toward(cam_y, player_y + _dead_zone_half, CAMERA_Y_SPEED * delta)
	elif player_y > cam_y + _dead_zone_half:
		# Jugador por debajo de la zona muerta → cámara baja hacia él
		cam_y = move_toward(cam_y, player_y - _dead_zone_half, CAMERA_Y_SPEED * delta)

	# La cámara no puede subir por encima del techo del nivel (y=0)
	_camera.global_position.y = maxf(cam_y, 0.0)
