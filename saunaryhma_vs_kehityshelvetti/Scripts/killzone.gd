extends Area2D

@onready var timer: Timer = $Timer

func _ready():
	# Correctly connect the body_entered signal to the _on_body_entered function
	connect("body_entered", Callable(self, "_on_body_entered"))

# Function called when any body enters the killzone
func _on_body_entered(body):
	print("Collision detected with: ", body.name)  # Debugging output
	if body.name == "Player1":  # Ensure that only the player triggers the kill
		print("Player killed!")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		timer.start()

func _on_timer_timeout():
	print("Timer finished, reloading the scene...")  # Debug
	Engine.time_scale = 1
	get_tree().reload_current_scene()  # Restart the game when the timer finishes
