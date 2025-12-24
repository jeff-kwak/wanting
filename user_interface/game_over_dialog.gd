class_name GameOverDialog
extends Control


signal quit_button_pressed
signal try_again_button_pressed


var message: String = "Game Over":
    get:
        return message
    set(value):
        message = value
        if _message_label:
            _message_label.text = message


@onready var _message_label: Label = %GameOverLabel


func _ready() -> void:
    message = message


func _on_quit_button_pressed() -> void:
    quit_button_pressed.emit()


func _on_try_again_button_pressed() -> void:
    try_again_button_pressed.emit()
