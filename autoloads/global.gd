extends Node

"""
Defines autoload globals.
"""

enum AFFECTOR {
    NONE,

    # ABILITIES
    MOVE,
    CHANGE_DIRECTION,
    PICKUP_ITEM,
    EXIT_LEVEL,
    UNLOCK_DOOR,
    ATTACK,
    DROP_ITEM,

    # STATUS EFFECTS
    HURT,
    INVINCIBLE,
}


enum STAT {
    NONE,
    SPEED
}


const GROUP_PLAYER: String = "Player"
const GROUP_MONSTER: String = "Monster"
const GROUP_VERMIN: String = "Vermin"

const TILE_SIZE: int = 16

const GOLDEN: float = 1.62
const SIZE_XS: int = int(SIZE_SM / GOLDEN)
const SIZE_SM: int = 8
const SIZE_MD: int = int(SIZE_SM * GOLDEN)
const SIZE_LG: int = int(SIZE_MD * GOLDEN)


const ANIM_DEATH: StringName = "death"
const ANIM_IDLE: StringName = "idle"
const ANIM_RUN: StringName = "run"

const ANIM_SHORT_ATTACK: StringName = "short_attack"
