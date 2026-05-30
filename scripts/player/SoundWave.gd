class_name SoundWave
extends Area2D

const WAVE_SPEED: float = 800.0
# La onda se destruye al superar esta distancia desde su origen
const MAX_TRAVEL: float = 900.0

var _start_x: float

func _ready() -> void:
	_start_x = global_position.x
	_setup_placeholder()

func _process(delta: float) -> void:
	position.x += WAVE_SPEED * delta
	if global_position.x > _start_x + MAX_TRAVEL:
		queue_free()

func _setup_placeholder() -> void:
	# Círculo degradado blanco semitransparente hasta tener el asset definitivo
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var center := Vector2(16.0, 16.0)
	for y in 32:
		for x in 32:
			var d := Vector2(x, y).distance_to(center)
			if d < 16.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, (1.0 - d / 16.0) * 0.75))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
