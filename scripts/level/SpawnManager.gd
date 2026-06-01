class_name SpawnManager
extends Node2D

const FLOOR_Y: float = 660.0
const CEILING_Y: float = 0.0
const OBSTACLE_WIDTH: float = 60.0
# Margen mínimo entre el borde del gap y el techo/suelo
const GAP_MARGIN: float = 50.0

# Texturas de obstáculos (se cargan si existen, sino usa placeholder)
const STALACTITE_TOP_PATH := "res://assets/sprites/obstacles/stalactite_top.png"
const STALACTITE_BOTTOM_PATH := "res://assets/sprites/obstacles/stalactite_bottom.png"

var _tex_top: Texture2D = null
var _tex_bottom: Texture2D = null

var _camera: Camera2D
var _viewport_half_width: float
var _next_spawn_x: float
var _active_pairs: Array = []

func setup(camera: Camera2D) -> void:
	_camera = camera
	_viewport_half_width = get_viewport().get_visible_rect().size.x * 0.5
	# Primera estalactita a 700 px: da ~1.75 s de margen antes del primer obstáculo
	_next_spawn_x = 700.0
	_load_textures()
	_fill_initial()

func _load_textures() -> void:
	if ResourceLoader.exists(STALACTITE_TOP_PATH):
		_tex_top = load(STALACTITE_TOP_PATH)
	if ResourceLoader.exists(STALACTITE_BOTTOM_PATH):
		_tex_bottom = load(STALACTITE_BOTTOM_PATH)

func _process(_delta: float) -> void:
	if _camera == null:
		return
	_spawn_ahead()
	_cull_behind()

# Genera pares hasta cubrir un spacing más allá del borde derecho de la cámara
func _spawn_ahead() -> void:
	var params: Dictionary = GameManager.get_biome_params()
	var spawn_until: float = _camera.global_position.x + _viewport_half_width + params.spacing
	while _next_spawn_x < spawn_until:
		_spawn_pair(_next_spawn_x, params)
		_next_spawn_x += params.spacing

# Elimina pares que han quedado fuera del borde izquierdo de la cámara
func _cull_behind() -> void:
	var cull_x: float = _camera.global_position.x - _viewport_half_width - OBSTACLE_WIDTH
	for pair in _active_pairs.duplicate():
		if is_instance_valid(pair) and pair.global_position.x < cull_x:
			pair.queue_free()
			_active_pairs.erase(pair)

func _fill_initial() -> void:
	var params: Dictionary = GameManager.get_biome_params()
	var fill_until: float = _camera.global_position.x + _viewport_half_width + params.spacing
	while _next_spawn_x < fill_until:
		_spawn_pair(_next_spawn_x, params)
		_next_spawn_x += params.spacing

func _spawn_pair(x: float, params: Dictionary) -> void:
	var gap_half: float = params.gap * 0.5
	var min_cy: float = CEILING_Y + gap_half + GAP_MARGIN
	var max_cy: float = FLOOR_Y - gap_half - GAP_MARGIN
	var cy: float = randf_range(min_cy, max_cy)

	var pair := Node2D.new()
	add_child(pair)
	pair.position = Vector2(x, 0.0)

	# Estalactita superior: desde el techo (y=0) hasta cy − gap_half
	var top_h: float = cy - gap_half - CEILING_Y
	if top_h > 1.0:
		_add_stalactite(pair, Vector2(0.0, top_h * 0.5), Vector2(OBSTACLE_WIDTH, top_h), true)

	# Estalactita inferior: desde cy + gap_half hasta el suelo (y=660)
	var bot_top: float = cy + gap_half
	var bot_h: float = FLOOR_Y - bot_top
	if bot_h > 1.0:
		_add_stalactite(pair, Vector2(0.0, (bot_top + FLOOR_Y) * 0.5), Vector2(OBSTACLE_WIDTH, bot_h), false)

	_active_pairs.append(pair)

func _add_stalactite(parent: Node2D, local_pos: Vector2, size: Vector2, is_top: bool) -> void:
	var body := StaticBody2D.new()
	body.position = local_pos
	body.add_to_group("obstacle")

	# Hitbox
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)

	# Visual: textura si existe, sino placeholder
	var tex: Texture2D = _tex_top if is_top else _tex_bottom

	if tex != null:
		# Usar sprite con textura escalado según altura del obstáculo
		var sprite := Sprite2D.new()
		sprite.texture = tex

		# Escalar sprite para que coincida con el tamaño del obstáculo
		# Asumir que la textura original es ~60px de ancho (OBSTACLE_WIDTH)
		var tex_size := tex.get_size()
		var scale_x: float = size.x / tex_size.x if tex_size.x > 0 else 1.0
		var scale_y: float = size.y / tex_size.y if tex_size.y > 0 else 1.0
		sprite.scale = Vector2(scale_x, scale_y)

		body.add_child(sprite)
	else:
		# Fallback: Polygon2D marrón como antes
		var visual := Polygon2D.new()
		var hw: float = size.x * 0.5
		var hh: float = size.y * 0.5
		visual.polygon = PackedVector2Array([
			Vector2(-hw, -hh), Vector2(hw, -hh),
			Vector2(hw, hh), Vector2(-hw, hh),
		])
		visual.color = Color(0.45, 0.25, 0.1)
		body.add_child(visual)

	parent.add_child(body)
