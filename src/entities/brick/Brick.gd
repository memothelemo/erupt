class_name Brick
extends RigidBody2D

## Score awarded when this brick is destroyed.
@export var points = 10

signal destroyed(points: int)

## Prevent repeated collision contacts from awarding points more than once.
var _destroyed = false

func hit() -> void:
	if self._destroyed: return

	self._destroyed = true
	self.destroyed.emit(self.points)
	self.queue_free()
