extends Node

class LazyCallable:
	var _modulo: int
	var _target: int
	var _callable: Callable
	var _loops: int
	
	func _init(id: int, modulo: int, callable: Callable, loops: int = 0) -> void:
		_modulo = modulo
		_target = id % modulo
		_callable = callable
		_loops = loops
	
	func process(frames: int) -> bool:
		if frames % _modulo == _target:
			_callable.call()
			if _loops > 0:
				_loops -= 1
		return true if _loops == 0 else false

var pool: Dictionary[int, LazyCallable] = {}

func queue(object_id: int, modulo: int, callable: Callable, loops: int = 0) -> void:
	if pool.has(object_id):
		push_error()
		return
	pool[object_id] = LazyCallable.new(object_id, modulo, callable, loops)
	if not is_processing():
		set_process(true)

func dequeue(object_id: int) -> void:
	pool.erase(object_id)
	if pool.is_empty():
		set_process(false)

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	var frames := Engine.get_process_frames()
	for id in pool.keys():
		if pool[id].process(frames):
			dequeue(id)
