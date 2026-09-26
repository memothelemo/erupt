extends Node2D

signal brick_destroyed(points: int)

@export var brick_scene: PackedScene
@export_range(1, 20) var rows = 6
@export_range(1, 30) var columns = 12
@export var spacing = Vector2(8, 8)
@export var top_margin = 160.0

## Size of the brick scene's rectangular collision shape.
var _brick_size: Vector2

func _ready() -> void:
	self._generate_bricks()
	self.get_viewport().size_changed.connect(self._layout_bricks)

func _generate_bricks() -> void:
	assert(self.brick_scene != null, "%s: brick scene must be set" % self.name)

	for row in range(self.rows):
		for column in range(self.columns):
			var brick = self.brick_scene.instantiate() as Node2D
			brick.name = "Brick_%d_%d" % [row + 1, column + 1]
			brick.set_meta(&"grid_position", Vector2i(column, row))
			brick.destroyed.connect(self.brick_destroyed.emit)

			if row == 0 and column == 0:
				var collision = brick.get_node("CollisionShape2D") as CollisionShape2D
				self._brick_size = (collision.shape as RectangleShape2D).size

			self.add_child(brick)

	self._layout_bricks()

func _layout_bricks() -> void:
	var screen_width = self.get_viewport_rect().size.x
	var grid_width = self.columns * self._brick_size.x + (self.columns - 1) * self.spacing.x
	var origin = Vector2((screen_width - grid_width) / 2, self.top_margin)

	# Keep surviving bricks in their original cells after others are destroyed.
	for child in self.get_children():
		var brick = child as Node2D
		var grid_position: Vector2i = brick.get_meta(&"grid_position")
		brick.position = origin + self._brick_size / 2 \
			+ Vector2(grid_position) * (self._brick_size + self.spacing)
