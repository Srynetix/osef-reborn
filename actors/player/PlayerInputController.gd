extends "res://actors/player/BaseInputController.gd"

########################
# Player Input Contoller

func _init(player).(player):
    pass

func process_input(delta):
    left_pressed = Input.is_action_pressed("ui_left")
    right_pressed = Input.is_action_pressed("ui_right")
    jump_pressed = Input.is_action_pressed("ui_up")
    attack_pressed = Input.is_action_pressed("ui_down")
    shield_pressed = Input.is_action_pressed("shield")
