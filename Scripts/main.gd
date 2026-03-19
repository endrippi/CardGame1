extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(2, 40):
		print("ciao ", i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
