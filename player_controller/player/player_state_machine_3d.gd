extends Node3D
class_name PlayerStateMachine3D

@export_category("Player Resources")
@export var character_body_3d: CharacterBody3D

@export_category("State Setup")
@export var default_state: PlayerState3D

var player_state_data: PlayerStateData3D
var current_state: PlayerState3D

var states: Dictionary[PlayerEnums.PlayerState, PlayerState3D] = {}

func _ready() -> void:
	player_state_data = PlayerStateData3D.new(
		character_body_3d,
		default_state.id()
	)
	states = _load_states()
	_on_transition_request(player_state_data.state)

func _load_states() -> Dictionary[PlayerEnums.PlayerState, PlayerState3D]:
	var result: Dictionary[PlayerEnums.PlayerState, PlayerState3D] = {}
	var children := get_children()
	for child in children:
		if child is PlayerState3D:
			result[child.id()] = child
		else:
			push_warning("Detected child not of type PlayerState3D: %s" % [child.name])
	return result

func _on_transition_request(
	to: PlayerEnums.PlayerState
) -> void:
	if not states.has(to):
		push_error("Attempted transition to unregistered state %s" % [to])
		return
	if current_state:
		if not current_state.can_transition(to):
			push_warning("Requested state %s is blocked by current state %s" % [to, current_state.id()])
			return
		current_state.exit()
	player_state_data.state = to
	current_state = states[to]
	current_state.enter(player_state_data)
	
