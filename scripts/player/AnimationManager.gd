class_name AnimationManager
extends Node

# Gestiona las animaciones del murciélago.
# El AnimatedSprite2D usa un spritesheet con dos estados:
# - "glide": frames 0-1 a 4 fps (planeando)
# - "flap": frames 0-7 a 18 fps (aleteando)

@onready var _sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

var _tween: Tween
var _current_anim: String = ""

# Planeando/cayendo: animación lenta con alas extendidas
func play_glide() -> void:
	if _current_anim == "glide":
		return
	_current_anim = "glide"
	if _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation("glide"):
		_sprite.play("glide")

# Aleteando/subiendo: animación rápida con ciclo completo
func play_flap() -> void:
	if _current_anim == "flap":
		return
	_current_anim = "flap"
	if _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation("flap"):
		_sprite.play("flap")

# Muerte: detiene animación + rotación + caída fuera de pantalla en 0.5 s
func play_die() -> void:
	_stop_tween()
	_current_anim = "die"
	if _sprite.sprite_frames != null:
		_sprite.stop()
		_sprite.play("die")
	_tween = create_tween().set_parallel()
	_tween.tween_property(_sprite, "rotation_degrees", 180.0, 0.5)
	_tween.tween_property(_sprite, "position:y", 800.0, 0.5)

# Impulso visual al saltar (no se usa, la animación flap ya proporciona feedback)
func play_jump_impulse() -> void:
	pass

func is_die_finished() -> bool:
	return _tween != null and not _tween.is_running()

func _stop_tween() -> void:
	if _tween != null and _tween.is_running():
		_tween.kill()
