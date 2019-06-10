extends Node

#######################
# Base Input Controller

var player = null

var jump_pressed = false
var attack_pressed = false
var left_pressed = false
var right_pressed = false
var shield_pressed = false

func _init(player):
    self.player = player

func reset():
    jump_pressed = false
    attack_pressed = false
    left_pressed = false
    right_pressed = false
    shield_pressed = false
