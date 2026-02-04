extends Node
@warning_ignore_start("unused_signal")

## Game management signals
signal start_menu_requested
signal credit_menu_requested
signal start_gameplay_requested


## Gameplay Events
signal level_exited(actor: Actor, level: Level)
signal level_entered(actor: Actor, level: Level)
signal door_unlocked(door: Door)
signal door_locked(door: Door)
signal actor_current_health_changed(actor: Actor, health: int)
signal actor_max_health_changed(actor: Actor, health: int)
signal actor_hurt(actor: Actor, amount: int)
signal actor_killed(actor: Actor)
signal attack_succeded(winner: Actor, loser: Actor)
signal attack_failed(winner: Actor, loser: Actor)
signal actor_stats_changed(actor: Actor)
signal actor_wallet_changed(actor: Actor, wallet_amount: int)


### ABILITY management signals
signal affector_activated(actor: Actor, affector: Affector)
signal affector_deactivated(actor: Actor, affector: Affector)
signal affector_cooldown_completed(actor: Actor, affector: Affector)
signal affector_cooldown_progress(actor: Actor, affector: Affector, remaining_time: float, total_time: float)

### PickupData management signals
signal item_picked_up(actor: Actor, item: PickupItem)
signal item_dropped(actor: Actor, item: PickupItem)
signal item_consumed(actor: Actor, item: PickupItem)

@warning_ignore_restore("unused_signal")
