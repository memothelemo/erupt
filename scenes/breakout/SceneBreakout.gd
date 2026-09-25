class_name SceneBreakout
extends Node2D

@onready var paddle: Paddle = $Paddle

func _move_paddle(pixels_dt: int) -> void:
	var actual_size = self.paddle.get_actual_size()
	var screen_width = self.get_viewport().size.x

	# Clamp the paddle to prevent going beyond the screen boundaries
	var half_width = actual_size.x / 2
	self.paddle.position.x = clampf(
		self.paddle.position.x + pixels_dt,
		half_width,
		screen_width - half_width
	)

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0: self._move_paddle(direction * self.paddle.speed * delta)
