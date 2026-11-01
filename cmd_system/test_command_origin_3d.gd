extends Node3D

func _ready() -> void:
	CameraService.camera_target = self
	CommandService.emitters.append(self)

func _physics_process(delta: float) -> void:
	var tick := Time.get_ticks_msec() * 0.025 * delta
	var dist := 3.5
	global_position.x = sin(tick) * dist
	global_position.z = cos(tick) * dist
