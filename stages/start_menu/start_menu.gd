class_name StartMenu
extends Node2D


func _on_play_button_pressed() -> void:
    print("start_menu: play pressed")
    EventBus.start_gameplay_requested.emit()


func _on_credits_button_pressed() -> void:
    print("start_menu: credits pressed")
    EventBus.credit_menu_requested.emit()
