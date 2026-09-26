class_name StatefulSceneProvider
extends Node

@export var resource: PackedScene

## Runtime instance managed by SceneStateMachine
##
## This is for internal use only. Use `get_scene` if you want to
## get the current scene instance of that resource.
var scene: StatefulScene

## Whether to reset the scene to its defaults whenever it is being reloaded.
##
## By default, it will not reset the scene.
func _should_reset_scene() -> bool: return false

## Gets the current scene instance.
func get_scene() -> StatefulScene: return self.scene

## Load on first use, then reuse the cached instance until it is reset.
func load_scene() -> StatefulScene:
	if is_instance_valid(self.scene) and not self.scene.is_queued_for_deletion():
		return self.scene

	if self.resource == null or not self.resource.can_instantiate(): return null

	var instance := self.resource.instantiate()
	if instance is not StatefulScene:
		push_warning("%s: scene root must extend StatefulScene" % self.name)
		instance.free()
		return null
	self.scene = instance as StatefulScene
	return self.scene

func _exit_tree() -> void:
	# Active scenes are owned by the host; detached cached scenes need cleanup.
	if is_instance_valid(self.scene) and self.scene.get_parent() == null:
		self.scene.queue_free()
