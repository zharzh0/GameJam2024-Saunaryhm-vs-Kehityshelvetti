extends CharacterBody2D  # Ensure this extends CharacterBody2D

# Declare Signals
signal died  # Emitted when the enemy dies

@export var can_levitate: bool = false  # Checkbox in Inspector
@export var SPEED = 1
@export var DETECTION_RADIUS = 200
const GRAVITY = 300

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var killzone: Area2D = $Killzone
@onready var idle_sound: AudioStreamPlayer2D = $IdleSound  # Refers to the idle sound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound  # Refers to the death sound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound



var player: CharacterBody2D = null
var is_following = false
var movement_velocity = Vector2.ZERO
var _health: int = 3  # Initial health
var knockback_strength: float = 300 
var knockback_deceleration: float = 100

func _ready() -> void:
	player = get_tree().get_root().get_node("Game/Player1")
	if player:
		player.connect("tree_exited", Callable(self, "_on_player_exited"))
	print("Enemy initialized. Player found: ", player != null)
	killzone.connect("body_entered", Callable(self, "_on_killzone_body_entered"))
	idle_sound.play()
	
func _process(delta: float) -> void:
	
	if not can_levitate:
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	# Check if the player is still valid
	if player:
		if not is_following:
			var distance_to_player = position.distance_to(player.position)
			if distance_to_player < DETECTION_RADIUS:
				is_following = true
				print("Following Player")

		if is_following:
			var direction_to_player =  (player.position - position).normalized()

			if can_levitate:
				movement_velocity = direction_to_player * SPEED
			else:
				direction_to_player.y = 0
				movement_velocity = direction_to_player * SPEED

			velocity.x = movement_velocity.x
			if can_levitate:
				velocity.y = movement_velocity.y

	move_and_slide()

	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0

func _on_killzone_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.call_deferred("queue_free")  # Safely queues the node for deletion


func take_damage(amount: int = 10, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	_health -= amount
	print("Enemy health: ", _health)
	
	hit_sound.play()

	# Apply knockback
	if knockback_direction != Vector2.ZERO:
		velocity = knockback_direction * knockback_strength

	# Check if the enemy's health reaches 0
	if _health <= 0:
		_health = 0
		died.emit()  # Emit the 'died' signal when health reaches zero
		die()

# A placeholder for velocity, assuming you have velocity handling


func die() -> void:
	print("Enemy died: ", self.name)
	idle_sound.stop()  # Stop the idle sound
	death_sound.play()  # Play the death sound
	await get_tree().create_timer(death_sound.stream.get_length()).timeout
	queue_free()

# Add these functions to handle sprite flipping
func face_left() -> void:
	$Sprite2D.flip_h = true

func face_right() -> void:
	$Sprite2D.flip_h = false

func _on_player_exited() -> void:
	player = null
