class_name State extends Node


var state_machine : StateMachine 
@onready var EntityRef = get_parent().get_parent()
signal transitioned

func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass

##Test per vedere se va
func _physics_update(_delta : float) -> void:
	pass
