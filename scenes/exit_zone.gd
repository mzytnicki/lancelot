extends Area2D
## A zone that triggers a scene transition when the player enters.

@export_file("*.tscn") var target_scene: String
@export var target_spawn_point: String = "default"


func _ready() -> void:
	# In Module 3, we connected signals through the editor UI. That works when both
	# sender and receiver are in the same scene and you are placing nodes manually.
	# But the exit zone script is designed to be reusable: attach it to any Area2D
	# in any scene and it just works. Connecting the signal in code means the
	# connection is self-contained. As your game grows, code-based connections
	# become the standard for reusable components.
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneManager.change_scene(target_scene, target_spawn_point)
