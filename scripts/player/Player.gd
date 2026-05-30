class_name Player
extends CharacterBody2D

signal player_died(distance: float)
signal wave_emitted

const JUMP_VELOCITY: float = -600.0
const GRAVITY: float = 1800.0
const WAVE_COOLDOWN: float = 1.0
# Escala: 100 px = 1 metro (a velocidad base de 400 px/s → 4 m/s)
const PIXELS_PER_METER: float = 100.0
# Toque 60% derecho → salto | 40% izquierdo → onda
const JUMP_TOUCH_X_RATIO: float = 0.4
# Mitad de CollisionShape2D (60 px de alto) — para detectar techo
const PLAYER_HALF_HEIGHT: float = 30.0

const WAVE_SCENE := preload("res://scenes/SoundWave.tscn")

var _alive: bool = true
var _wave_cooldown_timer: float = 0.0
var _screen_size: Vector2
var distance_meters: float = 0.0

func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	_setup_placeholder()

func _setup_placeholder() -> void:
	var img := Image.create(40, 60, false, Image.FORMAT_RGBA8)
	img.fill(Color.CYAN)
	$Sprite2D.texture = ImageTexture.create_from_image(img)

func _physics_process(delta: float) -> void:
	if not _alive:
		return
	_apply_gravity(delta)
	_tick_wave_cooldown(delta)
	velocity.x = GameManager.get_speed()
	move_and_slide()
	_check_obstacle_collisions()
	if not _alive:
		return
	distance_meters += GameManager.get_speed() * delta / PIXELS_PER_METER
	GameManager.update_distance(distance_meters)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _tick_wave_cooldown(delta: float) -> void:
	if _wave_cooldown_timer > 0.0:
		_wave_cooldown_timer -= delta

func _check_obstacle_collisions() -> void:
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider().is_in_group("obstacle"):
			die()
			return
	if is_on_floor() or is_on_ceiling():
		die()

func _input(event: InputEvent) -> void:
	if not _alive:
		return
	if event.is_action_pressed("jump"):
		_jump()
	elif event.is_action_pressed("wave"):
		_try_emit_wave()
	elif event is InputEventScreenTouch and event.pressed:
		if event.position.x >= _screen_size.x * JUMP_TOUCH_X_RATIO:
			_jump()
		else:
			_try_emit_wave()

func _jump() -> void:
	velocity.y = JUMP_VELOCITY

func _try_emit_wave() -> void:
	if _wave_cooldown_timer > 0.0:
		return
	_wave_cooldown_timer = WAVE_COOLDOWN
	var wave := WAVE_SCENE.instantiate() as Area2D
	wave.global_position = global_position
	get_parent().add_child(wave)
	wave_emitted.emit()

func die() -> void:
	if not _alive:
		return
	_alive = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process_input(false)
	player_died.emit(distance_meters)
