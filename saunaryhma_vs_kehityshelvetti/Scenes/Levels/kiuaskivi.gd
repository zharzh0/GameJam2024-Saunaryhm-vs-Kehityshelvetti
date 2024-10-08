extends Treasure

@export var _value : int = 1

func _collect():
	$/root/Game.collect_kivi(_value)
	call_deferred("set_freeze_enabled", true)
	call_deferred("set_freeze_mode", RigidBody2D.FREEZE_MODE_STATIC)
