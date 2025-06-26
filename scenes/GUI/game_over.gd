extends CanvasLayer

signal tryagain

func _ready() -> void:
	$Button.pressed.connect(tryagain.emit)

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE) and not event.is_echo():
		tryagain.emit()
		print("Eeee")
