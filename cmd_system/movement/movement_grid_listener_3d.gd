extends Node3D

const GRID_LETTERS := "abcdefgh"
const POINT_DISTANCE := 1.0
const COMMAND_PATTERN := "^(move|mv) \\w\\d$"

func _ready() -> void:
	CommandService.subscribe(
		COMMAND_PATTERN,
		on_command
	)

func on_command(args: Array) -> bool:
	return false

# generate a position 
# relative to the camera at a given plane
# based on given code (a1, b6, etc)
# `mv a1` or `a1`

# a1 = cam position + -4,-4

# generate the positions first, or calculate?

# find index of letter in string
# subtract half string length (ceili) from index
# a index = 0, 0 - 4 = -4
