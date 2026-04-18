class_name State extends Node


var state_machine : StateMachine 
@onready var EntityRef = get_parent().get_parent()
signal transitioned
@onready var gameData : GameData = null

func enter(data : GameData) -> void:
	pass


func exit(data : GameData) -> void:
	pass


func update(_delta: float) -> void:
	pass

##Test per vedere se va
func _physics_update(_delta : float) -> void:
	pass
