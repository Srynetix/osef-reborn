extends KinematicBody2D

#####
# Box

onready var sprite = $Sprite
onready var visibility_notifier = $VisibilityNotifier2D

const MIN_MOVE_SPEED = 100
const MAX_MOVE_SPEED = 500

const MIN_ANGULAR_SPEED = 1
const MAX_ANGULAR_SPEED = 10

var velocity = Vector2()
var angular_velocity = 0.0
var move_speed = 0
var angular_speed = 0

###################
# Lifecycle methods

func _ready():
    self.visibility_notifier.connect("screen_exited", self, "_on_screen_exited")
    self.sprite.frame = int(rand_range(0, 3))
    self.move_speed = rand_range(MIN_MOVE_SPEED, MAX_MOVE_SPEED)
    self.angular_speed = rand_range(MIN_ANGULAR_SPEED, MAX_ANGULAR_SPEED)

func _physics_process(delta):
    self.velocity = Vector2(-self.move_speed, 0)
    self.angular_velocity = self.angular_speed

    self.position += self.velocity * delta
    self.rotation += self.angular_velocity * delta

#################
# Event callbacks

func _on_screen_exited():
    self.queue_free()
