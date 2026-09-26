class_name BaseStateMachine
extends Node

## Signal that invokes every time new state has been transitioned.
##
## `previous` parameter is nullable.
signal state_changed(previous: BaseState, current: BaseState)

## Initial state. It must be initialized before starting the entire game.
@export var initial_state: BaseState

## Registered states from its children. Treat it as read-only.
var states: Dictionary[StringName, BaseState] = {}

## Current state of this machine.
var current_state: BaseState

## Every state's original process modes.
##
## This is for internal use only.
var _process_behaviors: Dictionary[BaseState, ProcessMode] = {}

func _ready() -> void:
	for child in self.get_children():
		if child is not BaseState: continue

		var state := child as BaseState
		_process_behaviors[state] = state.process_mode
		state.process_mode = Node.PROCESS_MODE_DISABLED

		if not _is_valid_state(state):
			push_warning("%s: invalid state '%s', skipping" % [self.name, child.name])
			continue

		self.states[state.name] = state
		state._transition_requested.connect(self._on_transition_requested.bind(state), CONNECT_DEFERRED)

	# wait until the entire game is ready to add a scene.
	self._start_machine.call_deferred()

func _get_initial_state() -> BaseState: return initial_state
func _start_machine() -> void:
	if not self.is_inside_tree(): return

	var state := self._get_initial_state()
	if state != null and not self._transition_to(state):
		push_warning("%s: could not transition to initial state" % self.name)

func _transition_to(state: BaseState) -> bool:
	if not is_instance_valid(state) or state.is_queued_for_deletion(): return false
	if not self._is_registered_state(state): return false
	if not self._is_valid_state(state): return false
	if state == self.current_state: return true

	var previous_state := self.current_state
	if is_instance_valid(previous_state):
		self._exit_state(previous_state)

	self.current_state = state
	self._enter_state(state)
	self.state_changed.emit(previous_state, current_state)

	if is_instance_valid(previous_state):
		print("%s: %s -> %s" % [self.name, previous_state.name, state.name])
	else:
		print("%s: %s (initial state)" % [self.name, state.name])

	return true

func _enter_state(state: BaseState) -> void:
	state.process_mode = self._process_behaviors[state] as ProcessMode
	state._on_state_entered()

func _exit_state(state: BaseState) -> void:
	state._on_state_exited()
	state.process_mode = Node.PROCESS_MODE_DISABLED

func _on_transition_requested(state: StringName, source: BaseState) -> void:
	# A delayed request must still come from the active registered state.
	if not is_instance_valid(source) or source != self.current_state: return

	var loaded_state = self._get_state(state)
	if loaded_state == null:
		push_warning("%s: tried to request transition to an unknown state (%s)" % [self.name, state])
		return

	if not self._transition_to(loaded_state as BaseState):
		print("%s: -> %s (failed)" % [self.name, state])

## Base function of whether a state is a valid state according to the
## implemented state machine.
##
## By default, it sets to `true` for `BaseStateMachine`.
func _is_valid_state(_state: BaseState) -> bool:
	return true

func _is_registered_state(state: BaseState) -> bool:
	return state.get_parent() == self and self.states.get(state.name) == state

func _get_state(state: StringName) -> BaseState:
	return self.states.get(state)
