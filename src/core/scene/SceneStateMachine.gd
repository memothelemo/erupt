class_name SceneStateMachine
extends BaseStateMachine

## Provider used to load the initial scene.
@export var initial_scene: StatefulSceneProvider

## Registered scene providers from its children. Treat it as read-only.
var providers: Dictionary[StringName, StatefulSceneProvider] = {}

## Every scene's provider.
##
## This is for internal use only.
var _scene_providers: Dictionary[BaseState, StatefulSceneProvider] = {}

func _ready() -> void:
	for child in self.get_children():
		if child is not StatefulSceneProvider: continue

		var provider := child as StatefulSceneProvider
		if provider.resource == null or not provider.resource.can_instantiate():
			push_warning("%s: invalid scene provider '%s', skipping" % [self.name, child.name])
			continue

		self.providers[provider.name] = provider

	# Require initial scene provider to be set.
	assert(self.initial_scene != null, "%s: initial scene provider must be set" % self.name)

	# Wait until the entire game is ready to add a scene.
	self._start_machine.call_deferred()

func _is_valid_state(state: BaseState) -> bool:
	return state is StatefulScene

func _get_initial_state() -> BaseState:
	if self.initial_scene == null: return null
	if self.providers.get(self.initial_scene.name) != self.initial_scene: return null

	return self._get_state(self.initial_scene.name)

func _get_state(state: StringName) -> BaseState:
	var provider := self.providers.get(state) as StatefulSceneProvider
	if provider == null: return null

	# Match the key type used by both state dictionaries explicitly.
	var scene: BaseState = provider.load_scene() as BaseState
	if scene == null: return null

	# Did we register the scene yet?
	if not self._scene_providers.has(scene):
		self._scene_providers[scene] = provider
		self._process_behaviors[scene] = scene.process_mode
		scene.process_mode = Node.PROCESS_MODE_DISABLED
		scene._transition_requested.connect(self._on_transition_requested.bind(scene), CONNECT_DEFERRED)

	self.states[state] = scene
	return scene

func _is_registered_state(state: BaseState) -> bool:
	var provider := self._scene_providers.get(state) as StatefulSceneProvider

	return is_instance_valid(provider) and provider.get_parent() == self \
		and self.providers.get(provider.name) == provider \
		and provider.get_scene() == state and self.states.get(provider.name) == state

func _enter_state(state: BaseState) -> void:
	var host := self.get_parent()

	# Initialize @onready references before invoking the live scene's callback.
	host.add_child(state)
	super._enter_state(state)

func _exit_state(state: BaseState) -> void:
	# Exit runs while the live scene and its children are still in the tree.
	super._exit_state(state)

	# Detach the scene out of the machine.
	state.get_parent().remove_child(state)

	# Dispose the scene if its provider allows the machine to do so.
	var provider := self._scene_providers[state]
	if provider._should_reset_scene():
		self.states.erase(provider.name)
		self._scene_providers.erase(state)
		self._process_behaviors.erase(state)
		provider.scene = null
		state.queue_free()
