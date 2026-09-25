class_name StatefulScene
extends BaseState

@export var resource: PackedScene

## Runtime instance managed by SceneStateMachine
##
## This is for internal use only. Use `get_scene` if you want to
## get the current scene instance of that resource.
var _scene: Node

## Whether to reset the scene to its defaults whenever it is being reloaded.
##
## By default, it will not reset the scene.
func _should_reset_scene() -> bool: return false

## Gets the current scene instance.
func get_scene() -> Node: return _scene
