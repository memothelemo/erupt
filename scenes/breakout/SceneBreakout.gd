class_name SceneBreakout
extends Node2D

@export var speed: float = 800.0


func _process(delta: float) -> void:
	var paddle := $Paddle
	var direction = Input.get_axis("ui_left", "ui_right")
	paddle.position.x += direction * speed * delta
