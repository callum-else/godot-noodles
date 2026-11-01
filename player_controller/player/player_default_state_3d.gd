extends PlayerState3D
class_name PlayerDefaultState3D

const MAX_VELOCITY: Vector3 = Vector3(1,0,1) * 6.0
const ACCELERATION: float = 8
const DECELERATION: float = 12

var body: CharacterBody3D
var is_active: bool = false

var movement_vector: Vector3 = Vector3.ZERO

func _ready() -> void:
	set_process(false)
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	var accelerating := movement_vector.length() > 0
	body.velocity = body.velocity.lerp(
		movement_vector * MAX_VELOCITY,
		delta * (ACCELERATION if accelerating else DECELERATION)
	)
	body.velocity = body.velocity.min(MAX_VELOCITY)
	body.move_and_slide()

func on_movement_vector_updated(vec: Vector2) -> void:
	movement_vector = Vector3(vec.x, 0, vec.y)

func id() -> PlayerEnums.PlayerState:
	return PlayerEnums.PlayerState.DEFAULT

func enter(data: PlayerStateData3D) -> void:
	if body == null:
		body = data.body
	EventService.movement_vector_updated.connect(on_movement_vector_updated)
	is_active = true
	set_process(true)
	set_physics_process(true)

func exit() -> void:
	is_active = false
	set_process(false)
	set_physics_process(false)
	EventService.movement_vector_updated.disconnect(on_movement_vector_updated)
	movement_vector = Vector3.ZERO

func can_transition(_to: PlayerEnums.PlayerState) -> bool:
	return true
