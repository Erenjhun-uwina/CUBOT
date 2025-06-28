extends CanvasLayer
class_name Gameover_screen

signal tryagain

func _ready() -> void:
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:return
	if Input.is_key_pressed(KEY_SPACE) and not event.is_echo():
		tryagain.emit()
		hide()
