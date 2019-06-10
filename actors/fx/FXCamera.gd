extends Node2D

###########
# FX Camera

onready var animation_player = $AnimationPlayer

###################
# Lifecycle methods

func _ready():
    pass

#################
# Private methods

################
# Public methods

func shake():
    self.animation_player.play("low_shake")
