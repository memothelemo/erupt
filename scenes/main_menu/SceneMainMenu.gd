class_name SceneMainMenu
extends StatefulScene

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start_game"):
		self.transition(&"Breakout")
