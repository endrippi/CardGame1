extends Button
@onready var label = %PlayLabel


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_mouse_entered() -> void:
	label.position += Vector2(0,5)


func _on_mouse_exited() -> void:
	label.position -= Vector2(0,5)
