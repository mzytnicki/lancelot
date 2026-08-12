extends Node
class_name BattleState
## Base class for all battle states.

var battle_manager: Node  # Set by BattleManager during _ready()

## Called when this state becomes active.
func enter(_context: Dictionary = {}) -> void:
	pass

## Called every frame while this state is active.
func process(_delta: float) -> void:
	pass

## Called when transitioning away from this state.
func exit() -> void:
	pass
