class_name Ball
extends RigidBody2D

## Minimum initial angle to shoot, it must not go beyond 90 degrees (π/2).
@export var min_initial_angle = 35

## Current ball shooting angle in radians
@export var angle = deg_to_rad(self.min_initial_angle)

## Ball movement speed in pixels per second.
@export var speed = 400.0

var rng = RandomNumberGenerator.new()

## Initial position for the ball
var initial_position = self.position

## Whether the ball has been launched.
var _moving = false

## Launch state applied when the physics body wakes from being frozen.
var _launch_pending = false
var _launch_transform: Transform2D

func _ready() -> void:
	assert(
		self.min_initial_angle > 0 and self.min_initial_angle <= 90,
		"minimum initial shoot angle must be greater than 0 and at most 90 degrees (π/2)"
	)

	# Disable the ball gravity
	self.gravity_scale = 0.0

	# Keep the ball from slowing down due to the project's default damping.
	self.linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	self.linear_damp = 0.0

func is_moving() -> bool: return self._moving

## Start the ball to continously move on a randomized shoot angle.
func start() -> void:
	self.angle = self._get_random_shoot_angle()
	self._launch_transform = self.global_transform
	self._launch_pending = true
	self._moving = true
	self.freeze = false
	self.sleeping = false

	# Negative Y shoots upward; the angle can point left or right.
	self.linear_velocity = Vector2(cos(self.angle), -sin(self.angle)) * self.speed
	print("Ball: set initial velocity (angle = %f, velocity=%s)" % [rad_to_deg(self.angle), self.linear_velocity])

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not self._moving: return

	var direction = Vector2(cos(self.angle), -sin(self.angle))

	# The first callback can contain contacts left over from the frozen body.
	# Apply the launch position and velocity before processing fresh contacts.
	if self._launch_pending:
		state.transform = self._launch_transform
		state.linear_velocity = direction * self.speed
		self._launch_pending = false
		return

	for contact in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(contact).rotated(state.transform.get_rotation())

		# Only reflect when travelling into the surface, not away from it.
		if direction.dot(normal) < 0: direction = direction.bounce(normal)

	# Preserve our upward-positive angle convention after the reflection.
	self.angle = atan2(-direction.y, direction.x)
	state.linear_velocity = direction * self.speed

func _get_random_shoot_angle() -> float:
	var minimum = deg_to_rad(self.min_initial_angle)
	return self.rng.randf_range(minimum, PI - minimum)
