extends StaticBody2D
tool

##########
# Platform

export (float) var width = 10
export (float) var height = 10

onready var color_rect = $ColorRect
onready var collision_shape = $CollisionShape2D

###################
# Lifecycle methods

func _ready():
    self._initialize_platform()

func _process(delta):
    # If in editor
    if Engine.is_editor_hint():
        self._initialize_platform()

#################
# Private methods

func _initialize_platform():
    # Set correct values in color rect
    self.color_rect.margin_left = -self.width;
    self.color_rect.margin_right = self.width;
    self.color_rect.margin_top = -self.height;
    self.color_rect.margin_bottom = self.height;

    # Set correct values in collision shape
    self.collision_shape.shape.extents.x = self.width
    self.collision_shape.shape.extents.y = self.height

#################
# Event callbacks
