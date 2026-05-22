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
	var parent = get_parent()
	print("Enabled clicks for ", parent.value, ' di ', parent.suit)
	clickable = true 

func disableClicks() -> void:
	var parent = get_parent()
	print("Disabled clicks for ", parent.value, ' di ', parent.suit)
	clickable = false
