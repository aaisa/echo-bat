class_name AnimationManager
extends Node

# Gestiona las animaciones del murciélago.
# El AnimatedSprite2D usa un spritesheet con dos estados:
# - "glide": frames 0-1 a 4 fps (planeando)
# - "flap": frames 0-7 a 18 fps (aleteando)

@onready var _sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

var _die_tween: Tween
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
	_current_anim = "die"
	if _sprite.sprite_frames != null:
		_sprite.stop()
		_sprite.play("die")
	if _die_tween != null and _die_tween.is_running():
		_die_tween.kill()
	_die_tween = create_tween().set_parallel()
	_die_tween.tween_property(_sprite, "rotation_degrees", 180.0, 0.5)
	_die_tween.tween_property(_sprite, "position:y", 800.0, 0.5)

func is_die_finished() -> bool:
	return _die_tween != null and not _die_tween.is_running()
