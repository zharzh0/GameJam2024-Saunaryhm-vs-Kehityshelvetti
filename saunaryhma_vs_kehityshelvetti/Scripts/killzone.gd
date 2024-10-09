extends Area2D

@onready var timer: Timer = $Timer

func _ready():
	pass


# Function called when any body enters the killzone
func _on_body_entered(body):
	print("Collision detected with: ", body.name)  # Debugging output
	if body.name == "Player1" and body.has_method("take_damage"):
		body.take_damage()  # Call the take_damage method on the player
		if body._health <= 0:
			print("Player killed!")
			Engine.time_scale = 0.5
			body.get_node("CollisionShape2D").queue_free()
			timer.start()

func _on_timer_timeout():
	print("Timer finished, reloading the scene...")  # Debug
	Engine.time_scale = 1
	get_tree().reload_current_scene()  # Restart the game when the timer finishes
