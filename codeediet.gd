extends Control

@export var runner:Runner
@onready var code_edit: Gameboard = $PanelContainer/VBoxContainer/CodeEdit

signal run

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().show()

	visibility_changed.connect(func():
		
		if code_edit.text.is_empty():
			code_edit.text = "extends CPU \n
			func start():\n
			\tpass\n
			func loop(delta):\n
			\tpass
			"
			
		if not visible:
			get_tree().paused = false
			return
		get_tree().paused = true

		)
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.volume_db = -80
		var twn:=create_tween()
		twn.tween_property($AudioStreamPlayer,"volume_db",0,3).set_ease(Tween.EASE_OUT)


func _on_button_pressed() -> void:
	
	var script = GDScript.new()
	var code:= code_edit.text
	script.source_code = code
	script.reload(true)

	runner.cubot.cpu  = script.new(runner.cubot)
	await Fade.fade_out(1,Color.BLACK,"GradientVertical",false,true).finished
	
	hide()
	run.emit()

	Fade.fade_in(1.5,Color.BLACK,"Diamond",true)

func _unhandled_key_input(event: InputEvent) -> void:
		if Input.is_key_pressed(KEY_F5) or Input.is_key_pressed(KEY_F6):
			_on_button_pressed()
