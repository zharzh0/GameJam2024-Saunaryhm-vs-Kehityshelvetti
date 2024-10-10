class_name Character extends CharacterBody2D

# Exported Categories and Variables
@export_category("Locomotion")
@export var _speed: float = 8
@export var _acceleration: float = 16
@export var _deceleration: float = 32

@export_category("Jump")
@export var _jump_height: float = 2.5
@export var _air_control: float = 0.5

@export_category("Sprite")
@export var _is_facing_left: bool
@export var _flipped: bool

@export_category("Attack")
@export var is_attacking: bool
@export var attack_duration: float = 0.2  # Duration in seconds the attack area is active
@export var attack_damage: int = 1  # Increased damage per attack
@export var attack_timer: Timer

# Nodes and References
@onready var _sprite: Sprite2D = $Sprite2D
@onready var melee_attack: Area2D = $MeleeAttack  # Reference to the MeleeAttack Area2D

# Internal Variables
var _is_bound: bool
var _min: Vector2
var _max: Vector2
var _was_on_floor: bool
var _jump_velocity: float

# Signals
signal died
signal changed_direction(is_facing_left: bool)
signal landed(floor_height: float)

# Physics and Movement
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction: float
var _health: int = 100  # Initial health value

# Attack Variables


# Default Offset for MeleeAttack
var melee_attack_default_offset_x: float = 26  # From scene's position.x

func _ready():
	# Initialize Movement Variables
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt
	_jump_height *= Global.ppt
	_jump_velocity = sqrt(_jump_height * gravity * 2) * -1

	# Set Initial Facing Direction
	if _is_facing_left:
		face_left()
	else:
		face_right()
	
	# Initialize Attack Timer
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_duration
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	add_child(attack_timer)
	
	# Connect 'body_entered' signal for MeleeAttack
	melee_attack.connect("body_entered", Callable(self, "_on_melee_attack_body_entered"))
	
	# Ensure MeleeAttack is Disabled Initially
	melee_attack.monitoring = false  # Corrected property

	# Store Default Offset
	melee_attack_default_offset_x = melee_attack.position.x

#region Public Methods


func set_bounds(min_boundary: Vector2, max_boundary: Vector2):
	_is_bound = true
	_min = min_boundary
	_max = max_boundary
	var sprite_size: Vector2 = _sprite.get_rect().size
	_min.x += sprite_size.x / 2
	_max.x -= sprite_size.x / 2
	_min.y += sprite_size.y / 2
	_max.y -= sprite_size.y / 2

func run(direction: float):
	_direction = direction

func jump():
	if is_on_floor():
		velocity.y = _jump_velocity

func stop_jump():
	if velocity.y < 0:
		velocity.y = 0

#endregion

func _physics_process(delta: float) -> void:
	# Handle Facing Direction Based on Movement
	if not _is_facing_left and sign(_direction) == -1:
		face_left()
	elif _is_facing_left and sign(_direction) == 1:
		face_right()
	
	# Handle Movement
	if is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
	
	_was_on_floor = is_on_floor()
	move_and_slide()
	
	# Emit Landed Signal
	if not _was_on_floor and is_on_floor():
		_landed()
	
	# Clamp Position Within Bounds
	if _is_bound:
		position.x = clamp(position.x, _min.x, _max.x)
		position.y = clamp(position.y, _min.y, _max.y)

func _ground_physics(delta: float):
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)
	elif velocity.x == 0 or sign(_direction) == sign(velocity.x):
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, _direction * _speed, _deceleration * delta)

func _air_physics(delta: float):
	velocity.y += gravity * delta
	if _direction != 0:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _air_control * delta)

func _landed():
	landed.emit(position.y)

func _spawn_dust(dust: PackedScene):
	var _dust = dust.instantiate()
	_dust.position = position
	_dust.flip_h = _sprite.flip_h
	get_parent().add_child(_dust)

# Health and Damage Methods

func take_damage(amount: int = 10) -> void:
	_health -= amount
	print("Health remaining: ", _health)
	if _health <= 0:
		_health = 0
		died.emit()  # Emit the 'died' signal when health reaches zero
		die()

func die() -> void:
	print("Character died: ", self.name)
	queue_free()

# Attack Methods

func attack() -> void:
	if not is_attacking:
		is_attacking = true
		melee_attack.monitoring = true  # Enable detection
		print("Attack initiated")
		
		# Detect and Damage Enemies
		var bodies = melee_attack.get_overlapping_bodies()
		print("Bodies detected: ", bodies.size())  # Debugging
		for body in bodies:
			print("Detected body: ", body.name)  # Debugging
			if body.has_method("take_damage"):
				body.take_damage(attack_damage)
				print("Damaged: ", body.name)
		
		# Start the Attack Timer to Disable MeleeAttack After Duration
		attack_timer.start()

func _on_attack_timer_timeout() -> void:
	melee_attack.monitoring = false  # Disable detection
	is_attacking = false
	print("Attack ended")
	

# Handle Bodies Entering MeleeAttack Area

func _on_melee_attack_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
		print("Damaged via signal: ", body.name)

func face_left() -> void:
	_sprite.flip_h = true
	_is_facing_left = true
	changed_direction.emit(_is_facing_left)

func face_right() -> void:
	_sprite.flip_h = false
	_is_facing_left = false
	changed_direction.emit(_is_facing_left)
