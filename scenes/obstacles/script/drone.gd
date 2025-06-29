extends Obstacle
class_name Drone_obstacle



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position.x -= 5
