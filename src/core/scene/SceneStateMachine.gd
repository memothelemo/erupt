class_name SceneStateMachine
extends BaseStateMachine

## Preferred property for the "initial state" property.
@export var initial_scene: StatefulScene

var current_scene: StatefulScene:
	get: return current_state as StatefulScene

func _ready() -> void:
	self.initial_state = self.initial_scene
	super._ready()

	# Require initial scene state to set
	assert(self._get_initial_state() != null, "%s: initial state must be set" % self.name)

func _is_valid_state(node: BaseState) -> bool:
	if node is not StatefulScene: return false

	var state = node as StatefulScene
	return state.resource != null and state.resource.can_instantiate()

func _get_initial_state() -> BaseState:
	return self.initial_scene \
		if self.initial_scene != null \
		else self.initial_state

func _enter_state(node: BaseState) -> void:
	assert(node is StatefulScene)

	var host := self.get_parent()
	var state = node as StatefulScene

	# Did we instantiate the scene yet?
	if not is_instance_valid(state.get_scene()):
		state._scene = state.resource.instantiate()
		# Scene scripts can call transition(); route requests through their
		# registered wrapper, whose signal is connected to the machine.
		if state._scene is BaseState:
			(state._scene as BaseState)._transition_requested.connect(state.transition)

	host.add_child((state as StatefulScene).get_scene())
	super._enter_state(state)

func _exit_state(node: BaseState) -> void:
	assert(node is StatefulScene)

	var state = node as StatefulScene
	super._exit_state(state)

	if is_instance_valid(state._scene):
		# Detach the scene out of the machine.
		state._scene.get_parent().remove_child(state._scene)

		# Dispose the scene if that scene allow the machine to do so.
		if state._should_reset_scene():
			state._scene.queue_free()
			state._scene = null
