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

var _sfx_jump: AudioStreamPlayer
var _sfx_die: AudioStreamPlayer
var _sfx_wave: AudioStreamPlayer

@onready var _anim: Node = $AnimationManager

func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	_setup_placeholder()
	_setup_audio()
	_anim.play_fly()

# --- Placeholder visual ---
# Sustituir por SpriteFrames con los assets reales cuando estén disponibles.
# bat_fly.png → 8 frames, 12 fps, loop
# bat_die.png → 6 frames, 10 fps, sin loop
func _setup_placeholder() -> void:
	var img := Image.create(40, 60, false, Image.FORMAT_RGBA8)
	img.fill(Color.CYAN)
	var tex := ImageTexture.create_from_image(img)

	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	frames.add_animation("fly")
	frames.set_animation_speed("fly", 12.0)
	frames.set_animation_loop("fly", true)
	for _i in 8:
		frames.add_frame("fly", tex)

	frames.add_animation("die")
	frames.set_animation_speed("die", 10.0)
	frames.set_animation_loop("die", false)
	for _i in 6:
		frames.add_frame("die", tex)

	$AnimatedSprite2D.sprite_frames = frames

# --- Audio ---

func _setup_audio() -> void:
	_sfx_jump = _make_sfx("res://assets/audio/flap.wav", 1.0)
	_sfx_die  = _make_sfx("res://assets/audio/golpe.wav", 1.0)
	_sfx_wave = _make_sfx("res://assets/audio/scream.wav", 0.1)

func _make_sfx(path: String, volume_linear: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.volume_db = linear_to_db(volume_linear)
	if ResourceLoader.exists(path):
		p.stream = load(path)
	add_child(p)
	return p

# --- Física ---

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

# --- Input ---

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
	_sfx_jump.play()

func _try_emit_wave() -> void:
	if _wave_cooldown_timer > 0.0:
		return
	_wave_cooldown_timer = WAVE_COOLDOWN
	var wave := WAVE_SCENE.instantiate() as Area2D
	wave.global_position = global_position
	get_parent().add_child(wave)
	_sfx_wave.play()
	wave_emitted.emit()

func die() -> void:
	if not _alive:
		return
	_alive = false
	velocity = Vector2.ZERO
	_sfx_die.play()
	_anim.play_die()
	set_physics_process(false)
	set_process_input(false)
	player_died.emit(distance_meters)
