extends Area2D

@export_file("*.tscn") var next_scene_path: String

func _on_body_entered(body):
	print("Body entered: ", body.name)  # Debug print
	print("Body collision layer: ", body.collision_layer)  # Debug print
	print("Body collision mask: ", body.collision_mask)  # Debug print
	if body.name == "Player1" or body.is_in_group("Player"):
		print("Player entered transition zone")  # Debug print
		if next_scene_path:
			print("Changing scene to: ", next_scene_path)  # Debug print
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("No scene specified for transition")
	else:
		print("Non-player body entered transition zone")  # Debug print

func _ready():
	print("LevelTransitionZone ready, next_scene_path: ", next_scene_path)  # Debug print
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Set collision mask to detect player (layer 9)
	collision_mask = 256  # This is equivalent to 1 << 8
	print("LevelTransitionZone collision_mask: ", collision_mask)  # Debug print
