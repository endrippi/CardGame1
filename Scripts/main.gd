class_name Main
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
