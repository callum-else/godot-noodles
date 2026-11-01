extends Camera3D
class_name ViewCamera3D

const FOLLOW_SPEED := 5.0
const Y_OFFSET := 10.0

func _physics_process(delta: float) -> void:
	var target_pos := CameraService.camera_target.global_position
	target_pos.y = Y_OFFSET
	global_position = global_position.lerp(
		target_pos,
		FOLLOW_SPEED * delta
	)
	
