extends CharacterBody3D
class_name Player3D

#func _ready() -> void:
	#EventService.movement_vector_updated.connect(on_movement_vector_updated)

#func _physics_process(_delta: float) -> void:
	#move_and_slide()

#func on_movement_vector_updated(vec: Vector2) -> void:
	#velocity = Vector3(vec.x, 0, vec.y)
