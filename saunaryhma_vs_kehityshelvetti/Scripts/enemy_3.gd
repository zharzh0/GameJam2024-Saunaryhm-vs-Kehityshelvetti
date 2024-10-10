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

var player: CharacterBody2D = null
var is_following = false
var movement_velocity = Vector2.ZERO
var _health: int = 3  # Initial health

func _ready() -> void:
	player = get_tree().get_root().get_node("Game/Player1")
	print("Enemy initialized. Player found: ", player != null)
	killzone.connect("body_entered", Callable(self, "_on_killzone_body_entered"))
	idle_sound.play()
	
func _process(delta: float) -> void:
	if not can_levitate:
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	

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


func take_damage(amount: int = 10) -> void:
	_health -= amount
	print("Enemy health: ", _health)
	if _health <= 0:
		_health = 0
		died.emit()  # Emit the 'died' signal when health reaches zero
		die()

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
