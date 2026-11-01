@abstract
extends Node3D
class_name PlayerState3D

@warning_ignore("unused_signal")
signal transition(
	from: PlayerEnums.PlayerState,
	to: PlayerEnums.PlayerState)

@abstract
func id() -> PlayerEnums.PlayerState

@abstract
func can_transition(to: PlayerEnums.PlayerState) -> bool

@abstract
func enter(data: PlayerStateData3D) -> void

@abstract
func exit() -> void
