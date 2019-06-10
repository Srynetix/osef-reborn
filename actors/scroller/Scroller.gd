extends Node2D
tool

#################
# Scroller script

export (Texture) var texture;
export (float) var scroll_speed = 100;
export (Vector2) var texture_scale = Vector2(1, 1);

onready var sprite = $Sprite;

var texture_size = null

func _ready():
    if not self.texture:
        return

    self.texture_size = texture.get_size()
    self.sprite.texture = self.texture
    self.sprite.scale = self.texture_scale

    # Set region
    self.sprite.region_enabled = true
    # Set rect
    self.sprite.region_rect.size.x = texture_size.x * 2
    self.sprite.region_rect.size.y = texture_size.y

func _process(delta):
    if not self.texture:
        return

    # Move sprite by speed
    var movement = scroll_speed * delta
    self.sprite.region_rect.position.x += movement
    if self.sprite.region_rect.position.x > texture_size.x:
        self.sprite.region_rect.position.x -= texture_size.x
