extends Area3D
class_name LocalCommandListener3D

@warning_ignore_start("unused_signal")

signal register_command()
signal unregister_command()

@warning_ignore_restore("unused_signal")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(PhysicsLayers.LOCAL_COMMAND, true)
	monitoring = false
	monitorable = true
