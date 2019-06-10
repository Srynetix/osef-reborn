extends Node2D

#############
# Test player

onready var camera = $FXCamera

func _ready():
    var players = self.get_tree().get_nodes_in_group("Player")
    for player in players:
        player.connect("died", self, "_on_player_died")

func _on_player_died():
    camera.shake()
