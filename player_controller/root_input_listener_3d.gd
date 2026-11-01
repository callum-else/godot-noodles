extends Node3D
class_name RootInputListener3D

const MOVEMENT_PUBLISH_THRESHOLD: float = 0.1

var movement_vector: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	handle_movement()

func handle_movement() -> void:
	var new_movement = Input.get_vector(
		"input_left", "input_right",
		"input_up", "input_down")
	if new_movement.distance_to(movement_vector) >= MOVEMENT_PUBLISH_THRESHOLD:
		movement_vector = new_movement
		EventService.movement_vector_updated.emit(movement_vector)
