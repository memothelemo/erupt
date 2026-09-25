class_name Paddle
extends CharacterBody2D

@export var speed = 600.0
@onready var _sprite: Sprite2D = $Sprite2D

## Gets the actual size of the paddle in pixels
func get_actual_size() -> Vector2:
	var texture_size = self._sprite.texture.get_size()
	return texture_size * self._sprite.scale
