extends Area2D
class_name Obstacle
var size:Vector2

var obs_type:String:
	get():
		if self is Drone_obstacle:return "DRONE"
		if self is Barrel_obstacle:return "BARREL"
		if self is Stump_obstacle:return "STUMP"
		return "ROCK"
	set(val):
		pass

@export var visibility_notifier: VisibleOnScreenNotifier2D 

var x:
	get():return global_position.x
	set(val):return
var y:
	get():return global_position.y
	set(val):return

func _ready() -> void:
	visibility_notifier.screen_exited.connect(
		_on_visible_on_screen_notifier_2d_screen_exited
	)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(.6).timeout
	queue_free()
