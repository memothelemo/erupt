class_name SceneBreakout
extends StatefulScene

@onready var ball: Ball = $Ball
@onready var begin_sfx: AudioStreamPlayer2D = $Begin
@onready var paddle: Paddle = $Paddle
@onready var score: int = 0

## Calls every time when a player gains points to their score.
@warning_ignore("unused_signal")
signal score_changed(new_score: int)

func _on_state_entered() -> void:
	begin_sfx.play()

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

func _start_moving_ball() -> void:
	if not self.ball.is_moving(): self.ball.start()

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		self._start_moving_ball()
		self._move_paddle(direction * self.paddle.speed * delta)
