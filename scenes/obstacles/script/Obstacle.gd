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
