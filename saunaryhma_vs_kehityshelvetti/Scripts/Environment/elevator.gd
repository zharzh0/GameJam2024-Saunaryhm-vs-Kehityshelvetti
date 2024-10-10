extends Area2D
@export var _is_locked : bool
@export var _is_open : bool
# The level to load after the door opens


# Function called when the player enters the elevator
func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		if not _is_locked:
			_is_open = true # Play the door opening animation
