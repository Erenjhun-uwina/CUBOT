extends Node2D
class_name CPU

var has_jump_request:bool = false
var has_duck_request:bool = false
@export var cubot:Cubot


func _init(_cubot:Cubot) -> void:
	cubot = _cubot

func get_speed()->float:
	return cubot.runner.speed

func init_state():
	clear_requests()
	
func clear_requests():
	has_jump_request = false
	has_duck_request = false

func jump():
	has_jump_request = true

func get_visible_objs():
	return cubot.get_tree().get_nodes_in_group("obstacle") as Array[Obstacle]

func get_nearest_obs()->Obstacle:
	var nearest:Obstacle
	var nearest_dist:float = 0
	
	for obs in get_visible_objs():
		if not nearest:
			nearest = obs
			nearest_dist = cubot.global_position.distance_to(obs.global_position)
			continue
		
		if cubot.global_position.distance_to(obs.global_position) < nearest_dist:
			nearest = obs
			nearest_dist = cubot.global_position.distance_to(obs.global_position)
			
	return nearest

func start():
	#jump()
	pass

func loop(delta:float):
	pass
##ad
##asd
#func loop(delta:float):
	#var nearest:Obstacle = get_nearest_obs()
	#
	#if not  nearest:return
	#var dist = abs(nearest.x - cubot.x)
	#
	#if dist < 150 and dist > 100:jump()
