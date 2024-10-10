

extends Area2D

@onready var timer: Timer = $Timer

func _ready():
	pass

# Function called when any body enters the killzone
func _on_body_entered(body):
	if body.name == "Player1" and body.has_method("take_damage"):
		var direction_to_player = (body.global_position - global_position).normalized()
		body.take_damage(direction_to_player, 10)  # You can add a custom knockback here if needed

		# Assuming the direction is from the killzone to the player:
		  # Call the take_damage method on the player with direction
		if body._health <= 0:
			print("Player killed!")
			Engine.time_scale = 0.5
			body.get_node("CollisionShape2D").queue_free()
			timer.start()

func _on_timer_timeout():
	print("Timer finished, reloading the scene...")  # Debug
	Engine.time_scale = 1
	get_tree().reload_current_scene()  # Restart the game when the timer finishes
