extends Node2D
## Visual representation of a combatant in battle.

var battler_data: BattlerData

@onready var _sprite: Sprite2D = $Sprite
@onready var _animation: AnimatedSprite2D = $Animation


func setup(data: BattlerData) -> void:
	battler_data = data
	add_to_group("battler_sprites")
	if data.character_data and data.character_data.animation:
		_animation.sprite_frames = data.character_data.animation
	elif data.character_data and data.character_data.portrait:
		_sprite.texture = data.character_data.portrait
	else:
		# Fallback so sprites are always visible during testing
		_sprite.texture = preload("res://icon.svg")
