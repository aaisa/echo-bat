class_name AnimationManager
extends Node

# Gestiona transiciones entre estados de animación del murciélago.
# Cuando lleguen los sprites reales, solo hay que actualizar SpriteFrames
# en Player.gd._setup_placeholder() sin tocar este script.

@onready var _sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

func play_fly() -> void:
	if _sprite.sprite_frames == null:
		return
	if _sprite.animation == "fly" and _sprite.is_playing():
		return
	_sprite.play("fly")

func play_die() -> void:
	if _sprite.sprite_frames == null:
		return
	_sprite.play("die")

func is_die_finished() -> bool:
	return _sprite.animation == "die" and not _sprite.is_playing()
