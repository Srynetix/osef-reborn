extends KinematicBody2D
tool

##########
# Obstacle

onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D

const MIN_MOVE_SPEED = 300
const MAX_MOVE_SPEED = 750
const MIN_ANGULAR_SPEED = 1
const MAX_ANGULAR_SPEED = 20

var velocity = Vector2()
var angular_velocity = 0.0
var move_speed = 0
var angular_speed = 0

###################
# Lifecycle methods

func _ready():
    if Engine.is_editor_hint():
        self._fit_collision_shape()
        return

    self.sprite.frame = int(rand_range(0, 3))
    self.move_speed = rand_range(MIN_MOVE_SPEED, MAX_MOVE_SPEED)
    self.angular_speed = rand_range(MIN_ANGULAR_SPEED, MAX_ANGULAR_SPEED)

    var scale_factor = rand_range(0.5, 1.5)
    self.scale.x = scale_factor
    self.scale.y = scale_factor

    self._fit_collision_shape()

func _physics_process(delta):
    self._fit_collision_shape()

    if Engine.is_editor_hint():
        return

    self.velocity = Vector2(-self.move_speed, 0)
    self.angular_velocity = self.angular_speed

    self.position += self.velocity * delta
    self.rotation += self.angular_velocity * delta

    # Check bounds
    self._check_bounds()

#################
# Private methods

func _fit_collision_shape():
    # Get current sprite frame
    var sprite_frame_idx = self.sprite.frame
    var sprite_anim = self.sprite.animation
    var sprite_frame = self.sprite.frames.get_frame(sprite_anim, sprite_frame_idx)
    var sprite_size = sprite_frame.get_size()

    self.collision_shape.shape.radius = sprite_size.x / 2
    self.collision_shape.shape.height = sprite_size.y / 2

func _check_bounds():
    if self.position.x < -100:
        self.queue_free()
