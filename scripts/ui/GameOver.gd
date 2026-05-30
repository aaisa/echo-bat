extends Control

@onready var _label_distance: Label = $VBoxContainer/LabelDistance
@onready var _label_record: Label = $VBoxContainer/LabelRecord
@onready var _btn_retry: Button = $VBoxContainer/ButtonRetry

func _ready() -> void:
	_label_distance.text = "%d m" % int(GameManager.last_distance)
	_label_record.text = "Récord: %d m" % int(GameManager.record_distance)
	_btn_retry.pressed.connect(_on_retry_pressed)

func _on_retry_pressed() -> void:
	GameManager.start_game()
