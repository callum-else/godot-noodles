extends RefCounted
class_name PlayerStateData3D

var body: CharacterBody3D
var state: PlayerEnums.PlayerState

func _init(
	character_body_3d: CharacterBody3D,
	default_state: PlayerEnums.PlayerState
) -> void:
	body = character_body_3d
	state = default_state
