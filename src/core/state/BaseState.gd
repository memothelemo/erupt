class_name BaseState
extends Node

## A signal that requests to the state machine to transition to another state.
##
## This signal is for internal use only. Call `transition` instead.
signal _transition_requested(state: StringName)

## Request to the state machine to transition into another state.
func transition(state: StringName) -> void:
	self._transition_requested.emit(state)

## Calls every time this state is set as the current state.
func _on_state_entered() -> void: pass

## Calls every time this state is being transitioned to a different state.
func _on_state_exited() -> void: pass
