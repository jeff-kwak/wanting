class_name WalletCounter
extends Label


var amount: int = 0:
    get:
        return amount
    set(value):
        amount = value
        text = "%d" % amount


func _ready() -> void:
    EventBus.actor_wallet_changed.connect(_on_actor_wallet_changed)
    amount = amount


func _on_actor_wallet_changed(actor: Actor, wallet_amount: int) -> void:
    if actor is not Player:
        return

    amount = wallet_amount
