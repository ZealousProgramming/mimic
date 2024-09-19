@tool
extends EditorPlugin

## TODOs:
#	- [ ] Preserve aspect ratio
#	- [ ] Configuration settings
#		- [ ] Default revert to editor override
#		- [ ] Aspect ratio stuff
## Notable bugs:
#	- Godot doesn't expose a signal for viewports to handle position, only size
#		so once the viewport is at the minimum_size, size no longer changes even though
#		the viewport's position still gets shifted. Try to expand the left panel as far 
#		as possible to see this.
#	- Godot doesn't expose a way to catch if the game was killed by the editor via
#		the stop button, so the notification we'd use in any other situation
#		doesn't apply to that specific situation. I'd like to have switched the 
#		active editor over to 3D on close like I do with normal close requests.

## The current version of the plugin
const VERSION: String = "0.1"
var _window_open: bool = false
var _debugger: MimicEditorDebugger = MimicEditorDebugger.new()
var _switch_scn: PackedScene = preload("res://addons/mimic/mimic_switch.tscn")
var _switch: MimicSwitch

func _enter_tree() -> void:
		# Initialization of the plugin goes here.
		print("[Mimic] Version %s.." % VERSION)
		print("[Mimic] Initializing..")

		# Initantiate the switch and add it to the toolbar
		_switch = _switch_scn.instantiate() as MimicSwitch
		_switch.setup_callback(_switch_mimic)
		_debugger.embed = _switch.toggle_mode
		add_control_to_container(CustomControlContainer.CONTAINER_TOOLBAR, _switch)

		add_debugger_plugin(_debugger)
		EditorInterface.get_editor_main_screen().resized.connect(_viewport_size_changed) 

func _exit_tree() -> void:
		remove_debugger_plugin(_debugger)
		if _switch:
				_switch.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
		pass

func _get_plugin_name():
	return "Game"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Window", "EditorIcons")

func _switch_mimic(toggled_on: bool) -> void:
		_debugger.embed = toggled_on

		if !toggled_on and EditorInterface.is_playing_scene():
				EditorInterface.set_main_screen_editor("3D")
		elif toggled_on and EditorInterface.is_playing_scene():
				EditorInterface.set_main_screen_editor("Game")
				

		var info: Array = [EditorInterface.get_editor_main_screen().get_screen_position(),
				EditorInterface.get_editor_main_screen().get_size()]
		_debugger.get_session(_debugger._session_id).send_message("mimic:embed", [_debugger.embed, info[0], info[1]])

func _viewport_size_changed() -> void:
		var info: Array = [EditorInterface.get_editor_main_screen().get_screen_position(),
				EditorInterface.get_editor_main_screen().get_size()]
		if _debugger.embed:
				_debugger.get_session(_debugger._session_id).send_message("mimic:resize", info)

class MimicEditorDebugger extends EditorDebuggerPlugin:
		var _session_id: int
		var embed: bool = false

		func _has_capture(prefix):
				# Return true if you wish to handle message with this prefix.
				return prefix.begins_with("mimic")

		func _capture(message, data, session_id):
				var handled: bool = false
				var kind: String = message.substr(6)
				
				match kind:
						"setup":
								if embed:
										EditorInterface.set_main_screen_editor("Game")
										get_session(session_id).send_message("mimic:setup", [EditorInterface.get_editor_main_screen().get_screen_position(), EditorInterface.get_editor_main_screen().get_size()])
								handled = true

						"shutdown":
								if embed:
										EditorInterface.set_main_screen_editor("3D")
										
								handled = true
						_:
								handled = false

				return handled

		func _setup_session(session_id):
				_session_id = session_id
