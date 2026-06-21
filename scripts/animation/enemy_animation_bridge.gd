class_name EnemyAnimationBridge
extends Node

@export var enemy: EnemyController
@export var anim: ActorAnimationController

func _process(delta: float) -> void:
    if enemy == null or anim == null: return
    match enemy.state:
        EnemyController.State.IDLE: anim.travel("idle")
        EnemyController.State.PATROL, EnemyController.State.CHASE: anim.set_locomotion(enemy.velocity, enemy.stats.move_speed)
        EnemyController.State.ATTACK: anim.travel("attack")
        EnemyController.State.STUNNED: anim.travel("stunned")
        EnemyController.State.DEAD: anim.travel("death")
