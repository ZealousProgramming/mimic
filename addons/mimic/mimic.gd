extends Node
class_name Mimic

var _initial_config: Dictionary = {
		"window_mode": 0,
		"initial_position": Vector2i(0, 0),
		"initial_size": Vector2i(0, 0),
		"borderless": false,
		"always_on_top": false,
}

func _ready() -> void:
		var window: Window = get_viewport().get_window()

		# Cache the initial configuration
		_initial_config["window_mode"] = window.mode
		_initial_config["initial_position"] = window.position
		_initial_config["initial_size"] = window.size
		_initial_config["borderless"] = window.borderless
		_initial_config["always_on_top"] = window.always_on_top

		# Setup the message callback
		EngineDebugger.register_message_capture("mimic", _message_callback)

		# Let the plugin know we're ready to setup
		EngineDebugger.send_message("mimic:setup", [])

func _notification(asd) -> void:
		match asd:
				NOTIFICATION_PREDELETE, NOTIFICATION_WM_CLOSE_REQUEST:
						EngineDebugger.send_message("mimic:shutdown", [])

func _message_callback(message: String, data: Array) -> bool:
		var handled: bool = false

		match message:
				"setup":
						var window: Window = get_viewport().get_window()
						
						window.mode = Window.Mode.MODE_WINDOWED
						window.borderless = true
						window.always_on_top = true
						
						if len(data) < 2:
								push_warning("[mimic] Attempting to setup window, but data provided is incompelte")
								return true
						var position: Vector2 = data[0]
						var size: Vector2 = data[1]
						
						resize(position, size)
						handled = true
				"resize":
						var position: Vector2 = data[0]
						var size: Vector2 = data[1]
						
						if len(data) < 2:
								push_warning("[mimic] Attempting to setup window, but data provided is incompelte")
								return true

						resize(position, size)
						handled = true
				"embed":
						var window: Window = get_viewport().get_window()
						var turn_on: bool = data[0]
						if turn_on:
								window.mode = Window.Mode.MODE_WINDOWED
								window.borderless = true
								window.always_on_top = true
								var position: Vector2 = data[1]
								var size: Vector2 = data[2]

								if len(data) < 3:
										push_warning("[mimic] Attempting to setup window, but data provided is incompelte")
										return true

								resize(position, size)
						else:
								window.borderless = _initial_config["borderless"]
								window.always_on_top = _initial_config["always_on_top"]
								window.mode = _initial_config["window_mode"]
								window.size = _initial_config["initial_size"]
								
						handled = true
				_:
						handled = false
						
		return handled

func resize(position: Vector2, size: Vector2) -> void:
		var window: Window = get_viewport().get_window()
		window.set_position(position)
		window.set_size(size)
