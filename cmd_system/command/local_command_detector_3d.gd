extends Area3D
class_name LocalCommandDetector3D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(PhysicsLayers.LOCAL_COMMAND, true)
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area3D) -> void:
	if area is LocalCommandListener3D:
		area.register_command.emit()

func _on_area_exited(area: Area3D) -> void:
	if area is LocalCommandListener3D:
		area.unregister_command.emit()
