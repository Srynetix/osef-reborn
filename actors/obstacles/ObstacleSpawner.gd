extends Node2D

##################
# Obstacle spawner

export (PackedScene) var obstacle
export (float) var spawn_delay = 1
export (bool) var disabled = false

onready var timer = $Timer
onready var elements = $Elements

###################
# Lifecycle methods

func _ready():
    self.timer.wait_time = self.spawn_delay
    self.timer.connect("timeout", self, "_on_timer_timeout")

#################
# Private methods

func _spawn_at(x, y):
    var instance = self.obstacle.instance()
    instance.position.x = x
    instance.position.y = y

    self.elements.add_child(instance)

func _spawn_at_random():
    var x = get_viewport().size.x + 100
    var y = rand_range(10, get_viewport().size.y)
    self._spawn_at(x, y)

#################
# Event callbacks

func _on_timer_timeout():
    # Bypass if disabled
    if self.disabled:
        return

    self._spawn_at_random()
