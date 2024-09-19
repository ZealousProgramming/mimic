@tool
extends Control
class_name MimicSwitch

func setup_callback(callback: Callable) -> void:
		self.toggled.connect(callback)
