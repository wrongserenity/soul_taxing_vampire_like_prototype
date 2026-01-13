extends CharacterBody2D

const SPEED = 100.0

var attack_delay := 1 # секунды
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
#func _ready():
	#$Timer.wait_time = attack_delay
	#$Timer.one_shot = true
#
#func attack_enemy(enemy):
	#$AttackIndicator.start()
	#enemy.take_damage(9)

func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	if input_vector[0] > 0:
		animated_sprite.flip_h = false
	elif input_vector[0] < 0:
		animated_sprite.flip_h = true
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * SPEED
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	#var target = $DetectionArea.get_nearest()
	#if target and is_instance_valid(target):
		#if $Timer.is_stopped():      # атака готова?
			#attack_enemy(target)
			#$Timer.start()
