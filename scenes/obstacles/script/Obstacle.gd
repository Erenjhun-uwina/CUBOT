extends Area2D
class_name Obstacle

var size:Vector2:
	get():return collision_shape.shape.get_rect().size.rotated(collision_shape.global_rotation).abs() * collision_shape.global_scale

var width:float:
	get():
		return size.x

var height:float:
	get():
		return size.y



@onready var collision_shape: CollisionShape2D = $CollisionShape2D


var obs_type:String:
	get():
		if self is Drone_obstacle:return "DRONE"
		if self is Barrel_obstacle:return "BARREL"
		if self is Stump_obstacle:return "STUMP"
		return "ROCK"
	set(val):
		pass

@export var visibility_notifier: VisibleOnScreenNotifier2D 

var x:float:
	get():return global_position.x
	set(val):return
	
var y:float:
	get():return global_position.y
	set(val):return

func _ready() -> void:
	
	visibility_notifier.screen_exited.connect(
		_on_visible_on_screen_notifier_2d_screen_exited
	)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(.6).timeout
	queue_free()
