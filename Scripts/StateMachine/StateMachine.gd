class_name StateMachine extends Node

@export var initial_state : State

var current_state: State

var states: Dictionary[String, State] = {}

@export var gameData : GameData = null

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
			print("Added ",child.name," to dictionary")
	
	if initial_state:
		initial_state.enter(gameData)
		current_state = initial_state

func on_child_transition(state : State, new_state_name : String):
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return

	if current_state:
		current_state.exit(gameData)
		
	new_state.enter(gameData)
	current_state = new_state
		

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta) 

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._physics_update(delta)


func change_state(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name.to_lower())
	
	assert(new_state, "State not found: "+ new_state_name)
	
	if current_state:
		current_state.exit(gameData)
	
	new_state.enter(gameData)
	
	current_state = new_state
