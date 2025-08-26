extends CanvasLayer
class_name Gameover_screen
@onready var score_label: Label = $ScoreLabel

signal tryagain

func _ready() -> void:
	
	
	visibility_changed.connect(
		func():
			if not visible:return
			score_label.text = "score:" + str((get_tree().current_scene as Runner).score/(get_tree().current_scene as Runner).SCORE_MODIFIER)
	)
	await get_tree().create_timer(0.01).timeout
	
	await Fade.fade_in(1,Color.BLACK,"GradientVertical",true,true).finished
	

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:return
	if Input.is_key_pressed(KEY_SPACE) and not event.is_echo():
		
		await Fade.fade_out(1,Color.BLACK,"GradientVertical",false,true).finished
		hide()
		tryagain.emit()
		await Fade.fade_in(1,Color.BLACK,"GradientVertical",true,true).finished

		
		
