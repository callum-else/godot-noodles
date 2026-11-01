extends Node3D

const ALLOWED_CHARACTERS := "abcdefghijklmnopqrstuvwxyz0123456789 "
const MAX_BUFFER_LENGTH := 50

var _command_buffer: String = ""

func _handle_submit() -> void:
	if _command_buffer.is_empty():
		return
	CommandService.emit(_command_buffer)
	_command_buffer = ""

func _handle_backspace() -> void:
	if _command_buffer.is_empty():
		return
	_command_buffer = _command_buffer.erase(
		_command_buffer.length() - 1
	)
	print(_command_buffer)

func _handle_typing(event: InputEventKey) -> void:
	if event.unicode == 0:
		return
	var character := char(event.unicode).to_lower()
	if (
		character in ALLOWED_CHARACTERS 
		and _command_buffer.length() < MAX_BUFFER_LENGTH
	):
		_command_buffer += character
		print(_command_buffer)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		_handle_submit()
		return
	if event.is_action_pressed("backspace"):
		_handle_backspace()
		return
	if event.is_pressed() and event is InputEventKey:
		_handle_typing(event)
