extends StaticBody2D

func _ready() -> void:
	self.get_viewport().size_changed.connect(self._update_boundaries)
	self._update_boundaries()

func _update_boundaries() -> void:
	var screen_size = self.get_viewport_rect().size
	$Right.position.x = screen_size.x
	$Bottom.position.y = screen_size.y
