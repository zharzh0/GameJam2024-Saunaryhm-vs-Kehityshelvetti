extends Camera2D

var _is_bound : bool
var _min : Vector2
var _max : Vector2

@export var _subject : Node2D
@export var _offset : Vector2
@export var _look_ahead_trans_type : Tween.TransitionType
@export var _look_ahead_ease_type : Tween.EaseType
@export var _look_ahead_duration : float = 1
@export var _floor_height_trans_type : Tween.TransitionType
@export var _floor_height_ease_type : Tween.EaseType
@export var _floor_height_duration : float = 1
@onready var _look_ahead_distance : float = _offset.x
@onready var _floor_height : float = _subject.position.y
var _look_ahead_tween : Tween
var _floor_height_tween : Tween

func _ready():
	_offset *= Global.ppt

func set_bounds(min_boundary : Vector2, max_boundary : Vector2):
	_is_bound = true
	_min = min_boundary
	_max = max_boundary
	var half_zoomed_size = get_viewport_rect().size / zoom / 2
	_min += half_zoomed_size
	_max -= half_zoomed_size

func _process(_delta : float):
	position.x = _subject.position.x + _look_ahead_distance
	position.y = _floor_height + _offset.y
	if _is_bound:
		position.x = clamp(position.x, _min.x, _max.x)
		position.y = clamp(position.y, _min.y, _max.y)

func _on_subject_changed_direction(is_facing_left: bool):
	if _look_ahead_tween && _look_ahead_tween.is_running():
		_look_ahead_tween.kill()
	_look_ahead_tween = create_tween().set_trans(_look_ahead_trans_type).set_ease(_look_ahead_ease_type)
	_look_ahead_tween.tween_property(self, "_look_ahead_distance", _offset.x * (1 if is_facing_left else -1), _look_ahead_duration)


func _on_subject_landed(floor_height: float) -> void:
	if _floor_height_tween and _floor_height_tween.is_running():
		_floor_height_tween.kill()
	_floor_height_tween = create_tween().set_trans(_floor_height_trans_type).set_ease(_floor_height_ease_type)
	_floor_height_tween.tween_property(self, "_floor_height", floor_height, _floor_height_duration)
