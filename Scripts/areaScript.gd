extends Area2D

signal card_clicked(left: bool)

# Called when the node enters the scene tree for the first time.
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("clickL"):
		card_clicked.emit(true)
	if event.is_action_pressed("clickR"):
		card_clicked.emit(false)
