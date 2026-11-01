extends Node3D

const COMMAND_RANGE := 1.0
const COMMAND_PATTERN := "^(local|loc|lcl)$"

@onready var listener: LocalCommandListener3D = $LocalCommandListener3D

func _ready() -> void:
	listener.register_command.connect(_on_register_command)
	listener.unregister_command.connect(_on_unregister_command)
	
func _on_register_command() -> void:
	CommandService.subscribe(COMMAND_PATTERN, _on_command)

func _on_unregister_command() -> void:
	CommandService.unsubscribe(COMMAND_PATTERN, _on_command)

func _on_command(_args: Array) -> bool:
	for emitter in CommandService.emitters:
		var dist = global_position.distance_to(emitter.global_position)
		if dist <= COMMAND_RANGE:
			print("LOCAL COMMAND FOR ID %s" % [get_instance_id()])
			return true
	return false
