extends Node

signal unrecognised_command(cmd_string: String)
signal failed_command(cmd: Command)

class CommandSubscription:
	var matcher: RegEx
	var callables: Array[Callable]
	func _init(pattern: String) -> void:
		matcher = RegEx.create_from_string(pattern)
		callables = []

var subscriptions: Dictionary[String, CommandSubscription] = {}
var emitters: Array[Node3D] = []

func subscribe(pattern: String, callable: Callable) -> void:
	if not subscriptions.has(pattern):
		subscriptions[pattern] = CommandSubscription.new(pattern)
	subscriptions[pattern].callables.append(callable)

func unsubscribe(pattern: String, callable: Callable) -> void:
	subscriptions[pattern].callables.erase(callable)

func clear() -> void:
	subscriptions.clear()

func emit(cmd_string: String) -> void:
	var subscription: CommandSubscription
	for pattern in subscriptions.keys():
		var current := subscriptions[pattern]
		if current.matcher.search(cmd_string) != null:
			subscription = current
			break
	if not subscription:
		unrecognised_command.emit(cmd_string)
		return
	var cmd := Command.parse(cmd_string)
	var result: Variant
	for callable in subscription.callables:
		result = callable.call(cmd.args)
		if result is not bool:
			push_error(
				"Subscriber for command '%s' does not return a bool"
				% cmd.command)
			result = false
		elif result:
			break
	if not result:
		failed_command.emit(cmd)
