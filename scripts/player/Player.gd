class_name Player
extends CharacterBody2D

const SPEED: float = 400.0
const JUMP_VELOCITY: float = -600.0
const GRAVITY: float = 1800.0
# Toque en el 60% derecho de la pantalla dispara el salto (x >= 40% del ancho)
const JUMP_TOUCH_X_RATIO: float = 0.4
# Umbral de prueba: al superar esta x, el jugador reaparece por la izquierda
const LOOP_WIDTH: float = 1600.0

var _screen_size: Vector2

func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	_setup_placeholder()

func _setup_placeholder() -> void:
	var img := Image.create(40, 60, false, Image.FORMAT_RGBA8)
	img.fill(Color.CYAN)
	$Sprite2D.texture = ImageTexture.create_from_image(img)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	velocity.x = SPEED
	move_and_slide()
	_wrap_horizontal()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_jump()
	elif event is InputEventScreenTouch and event.pressed:
		if event.position.x >= _screen_size.x * JUMP_TOUCH_X_RATIO:
			_jump()

func _jump() -> void:
	velocity.y = JUMP_VELOCITY

# Bucle de prueba sin nivel generado: al salir por la derecha reaparece por la izquierda
func _wrap_horizontal() -> void:
	if global_position.x > LOOP_WIDTH:
		global_position.x -= LOOP_WIDTH
