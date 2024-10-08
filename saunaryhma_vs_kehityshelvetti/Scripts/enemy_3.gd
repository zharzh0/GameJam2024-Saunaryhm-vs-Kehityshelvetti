extends CharacterBody2D  # Ensure this extends CharacterBody2D

# Add an exported variable for levitation
@export var can_levitate: bool = false  # This will be a checkbox in the Inspector

const SPEED = 200  # Adjust this to control enemy speed
const DETECTION_RADIUS = 200  # Distance at which the enemy will start following the player
const GRAVITY = 300  # Adjust as needed based on your game's physics

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var killzone: Area2D = $Killzone

var player: CharacterBody2D = null  # Reference to the player
var is_following = false
var movement_velocity = Vector2.ZERO  # Renamed to avoid conflict with built-in 'velocity'

func _ready() -> void:
	player = get_tree().get_root().get_node("Game/Player1")  # Access the parent node (Game) and get Player1
	print("Enemy initialized. Player found: ", player != null)  # Check if player is found
	killzone.connect("body_entered", Callable(self, "_on_killzone_body_entered"))

func _process(delta: float) -> void:
	# Apply gravity only if the enemy cannot levitate
	if not can_levitate:
		velocity.y += GRAVITY * delta  # Use built-in 'velocity' for vertical movement
	else:
		velocity.y = 0  # Prevent gravity when levitating

	if player:
		if not is_following:
			var distance_to_player = position.distance_to(player.position)
			if distance_to_player < DETECTION_RADIUS:
				is_following = true
				print("Following Player")

		if is_following:
			var direction_to_player = (player.position - position).normalized()

			# Adjust the movement vector based on the levitation setting
			if can_levitate:
				movement_velocity = direction_to_player * SPEED  # Move freely in all directions
			else:
				direction_to_player.y = 0  # Ensure the enemy only moves horizontally
				movement_velocity = direction_to_player * SPEED  # Horizontal movement

			velocity.x = movement_velocity.x  # Apply horizontal movement
			if can_levitate:
				velocity.y = movement_velocity.y  # Apply vertical movement only if levitating

	# Apply the velocity and handle collisions
	move_and_slide()  # Use built-in velocity for movement

	# Flip the sprite based on direction
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0
