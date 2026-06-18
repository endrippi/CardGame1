extends Button

@onready var label = %QuitLabel

func _on_pressed() -> void:
	get_tree().quit(0)


func _on_mouse_entered() -> void:
	label.position += Vector2(0,5)


func _on_mouse_exited() -> void:
	label.position -= Vector2(0,5)
