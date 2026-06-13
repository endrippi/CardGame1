class_name Main
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_P) and Input.is_key_pressed(KEY_O) and Input.is_key_pressed(KEY_I):
		HighScore.save_highscore(80)


func _on_reset_high_score_pressed() -> void:
	HighScore.save_highscore(80)
	get_tree().reload_current_scene()
