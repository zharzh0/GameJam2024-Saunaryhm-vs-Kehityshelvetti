extends Node2D

# Add an exported variable for levitation
@export var can_levitate: bool = false  # This will be a checkbox in the Inspector

const SPEED = 60
const DETECTION_RADIUS = 200  # Distance at which the enemy will start following the player

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCast2DLeft
@onready var killzone: Area2D = $Killzone

var player: CharacterBody2D = null  # Reference to the player
var is_following = false

func _ready() -> void:
	player = get_parent().get_node("Player1")  # Access the parent node (Game) and get Player1
	print("Enemy initialized. Player found: ", player != null)  # Check if player is found
	killzone.connect("body_entered", Callable(self, "_on_killzone_body_entered"))

func _process(delta: float) -> void:
	if player:
		if !is_following:  # Check if the enemy is not already following
			var distance_to_player = position.distance_to(player.position)
			if distance_to_player < DETECTION_RADIUS:
				is_following = true
				print("Following Player")  # Should print when in range

		if is_following:
			var direction_to_player = (player.position - position).normalized()
			
			# Adjust the Y position based on the levitation setting
			if can_levitate:
				# Keep levitating towards the player
				position += direction_to_player * SPEED * delta
			else:
				direction_to_player.y = 0  # Ensure the enemy doesn't levitate
				position += direction_to_player * SPEED * delta

			print("Moving towards Player")  # Debugging output for movement
