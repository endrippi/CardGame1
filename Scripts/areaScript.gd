extends Area2D

signal card_clicked(left: bool)
var clickable : bool = true

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		#print("evento registrato: ", event, ' su ', card.value, ' di ', card.suit)
		if clickable:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				card_clicked.emit(true)
			elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				card_clicked.emit(false)

func enableClicks() -> void:
	#print("Enabled clicks for ", card.value, ' di ', card.suit)
	clickable = true 

func disableClicks() -> void:
	#print("Disabled clicks for ", card.value, ' di ', card.suit)
	clickable = false
