extends RefCounted
class_name Command

const SPLIT_STRING := " "

var command: String
var args: Array

func _init(cmd: String, arg: Array) -> void:
	command = cmd
	args = arg

func command_string() -> String:
	return "%s %s" % [command, SPLIT_STRING.join(args)]

static func parse(cmd: String) -> Command:
	var split := cmd.split(SPLIT_STRING, false)
	return Command.new(
		split[0].to_lower(),
		split.slice(1)
	)
