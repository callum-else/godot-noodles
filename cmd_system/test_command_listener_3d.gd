extends Node3D

const COMMAND_PATTERN := "^(test|tst)$"

func _ready() -> void:
	CommandService.subscribe(
		COMMAND_PATTERN,
		on_test_command
	)
	CommandService.unrecognised_command.connect(
		on_unrecognised_command
	)

func on_test_command(args: Array) -> bool:
	LazyService.queue(
		get_instance_id(),
		3,
		func (): print("RECEIVED %s at %s" % [args, Engine.get_process_frames()])
	)
	#print("RECEIVED %s at %s" % [args, Engine.get_process_frames()])
	return true

func on_unrecognised_command(cmd_string: String) -> void:
	print("UNRECOGNISED: %s" % cmd_string)
