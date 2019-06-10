extends Node2D

var Box = load("res://actors/obstacles/Box.tscn")

onready var timer = $Timer
onready var obstacles = $Obstacles

func _ready():
    randomize()
    timer.connect("timeout", self, "_on_timer_timeout")

func _on_timer_timeout():
    var x = get_viewport().size.x
    var y = rand_range(10, get_viewport().size.y)

    var instance = Box.instance()
    instance.position.x = x
    instance.position.y = y

    obstacles.add_child(instance)
