class_name SoundWave
extends Area2D

const WAVE_SPEED: float = 800.0
# La onda se destruye al superar esta distancia desde su origen
const MAX_TRAVEL: float = 900.0

const WAVE_TEXTURE_PATH: String = "res://assets/sprites/effects/wave_ring.png"

var _start_x: float

func _ready() -> void:
	_start_x = global_position.x
	_setup_visual()

func _process(delta: float) -> void:
	position.x += WAVE_SPEED * delta
	if global_position.x > _start_x + MAX_TRAVEL:
		queue_free()

func _setup_visual() -> void:
	if ResourceLoader.exists(WAVE_TEXTURE_PATH):
		# Asset definitivo: wave_ring.png (128×128 px, 8 frames horizontal)
		$Sprite2D.texture = load(WAVE_TEXTURE_PATH)
		return
	# Placeholder: círculo degradado blanco semitransparente
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var center := Vector2(16.0, 16.0)
	for y in 32:
		for x in 32:
			var d := Vector2(x, y).distance_to(center)
			if d < 16.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, (1.0 - d / 16.0) * 0.75))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
