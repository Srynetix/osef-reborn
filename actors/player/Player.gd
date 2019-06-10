extends KinematicBody2D
tool

########
# Player

signal died

enum PlayerType {
    Player,
    AI,
}

var PlayerInputController = load("res://actors/player/PlayerInputController.gd")
var AIInputController = load("res://actors/player/AIInputController.gd")

export (PlayerType) var player_type = PlayerType.Player
export (String) var player_name = "Player"

onready var animation_player = $AnimationPlayer
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var shield_cooldown_timer = $ShieldCooldownTimer
onready var sprite = $Sprite
onready var visibility_notifier = $VisibilityNotifier2D
onready var collision_ray = $CollisionRay
onready var label = $HUD/Label

const GRAVITY = 1000.0
const DRAG_FORCE = 1300.0
const WALK_MIN_SPEED = 10.0
const WALK_MAX_SPEED = 350.0
const WALK_FORCE = 800.0
const JUMP_SPEED = 600.0
const JUMP_MAX_AIRBORNE_TIME = 0.2
const ATTACK_SPEED = 200.0
const ATTACK_KNOCKBACK = 650
const SHIELD_KNOCKBACK = 50
const HIT_DAMAGES = 8

var velocity = Vector2()
var hit_force = Vector2()
var on_air_time = 100
var direction = 1
var damages = 0

var jumping = false
var falling = false
var attacking = false
var blocking = false
var is_hit = false

var can_attack = true
var can_shield = true

var prev_jump_pressed = false
var prev_attack_pressed = false
var prev_shield_pressed = false

var input_controller = null

var spawn_position = null

###################
# Lifecycle methods

func _ready():
    # Store spawn position
    self.spawn_position = self.position

    # Load controller
    if self.player_type == PlayerType.Player:
        self.input_controller = PlayerInputController.new(self)
    else:
        self.input_controller = AIInputController.new(self)

    # Connect
    self.attack_cooldown_timer.connect("timeout", self, "_on_attack_cooldown_timer_timeout")
    self.shield_cooldown_timer.connect("timeout", self, "_on_shield_cooldown_timer_timeout")
    self.animation_player.connect("animation_finished", self, "_on_animation_finished")
    self.visibility_notifier.connect("screen_exited", self, "_on_screen_exited")

    # Set name
    self._update_label()

    # Run
    if not Engine.is_editor_hint():
        self.animation_player.play("running")

func _process(delta):
    self._update_label()

func _physics_process(delta):
    if Engine.is_editor_hint():
        return

    var force = Vector2(0, GRAVITY)

    # Ray orientation
    if self.direction == 1:
        self.collision_ray.cast_to.x = 50
    else:
        self.collision_ray.cast_to.x = -50

    # Input handling
    if self.is_hit or self.attacking or self.blocking:
        self.input_controller.reset()
    else:
        self.input_controller.process_input(delta)

    # Walk handling
    var stopped = true
    if self.input_controller.left_pressed:
        if self.velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
            force.x -= WALK_FORCE
            stopped = false
            direction = -1
    elif self.input_controller.right_pressed:
        if self.velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
            force.x += WALK_FORCE
            stopped = false
            direction = 1

    # Drag handling
    if stopped:
        var vsign = sign(self.velocity.x)
        var vlen = abs(self.velocity.x)

        vlen -= DRAG_FORCE * delta
        if vlen < 0:
            vlen = 0

        self.velocity.x = vlen * vsign

    # Block handling
    if self.input_controller.shield_pressed and not self.prev_shield_pressed and not self.blocking and self.can_shield:
        self.blocking = true
        self.can_shield = false

    # Attack handling
    if self.input_controller.attack_pressed and not self.prev_attack_pressed and not self.attacking and self.can_attack:
        self.velocity.x = ATTACK_SPEED * direction
        self.attacking = true
        self.can_attack = false

    # Is hit?
    if self.is_hit and self.hit_force.x != 0:
        # Reset force and velocity
        force = Vector2()
        self.velocity = self.hit_force

        # Reset hit force
        self.hit_force = Vector2()

    # Force integration and collisions
    self.velocity += force * delta

    # Move and slide
    self.velocity = self.move_and_slide(self.velocity, Vector2(0, -1))

    # Handle ray collisions
    if collision_ray.is_colliding():
        var collider = collision_ray.get_collider()
        if collider.is_in_group("Player"):
            # Handle player collisions
            self._collide_with_player(collider)

    # Jump handling
    if self.is_on_floor():
        self.on_air_time = 0.0
        self.falling = false
    if self.jumping and self.velocity.y > 0:
        self.jumping = false
        self.falling = true
    if self.on_air_time < JUMP_MAX_AIRBORNE_TIME and self.input_controller.jump_pressed and not self.prev_jump_pressed and not self.jumping:
        self.velocity.y = -JUMP_SPEED
        self.jumping = true

    # Animation handling
    if self.is_hit:
        self.animation_player.play("hit")
    elif self.blocking:
        self.animation_player.play("shield")
    elif self.attacking:
        self.animation_player.play("attacking")
    elif self.jumping:
        self.animation_player.play("jumping")
    elif self.falling:
        self.animation_player.play("falling")
    else:
        self.animation_player.play("running")

    # Sprite flip
    self.sprite.flip_h = direction == -1

    # State keeping
    self.on_air_time += delta
    self.prev_jump_pressed = self.input_controller.jump_pressed
    self.prev_attack_pressed = self.input_controller.attack_pressed
    self.prev_shield_pressed = self.input_controller.shield_pressed

#################
# Private methods

func _collide_with_player(player):
    var facing_player = false
    if direction == -1 and player.position.x < self.position.x:
        facing_player = true
    elif direction == 1 and player.position.x > self.position.x:
        facing_player = true

    if self.attacking and facing_player:
        if player.blocking:
            self.knockback()
        else:
            player.hit(self)

func _update_label():
    self.label.text = self.player_name + " - " + str(self.damages) + "%"

################
# Public methods

func hit(attacker):
    """Hit."""
    if self.is_hit:
        return

    self.is_hit = true
    self.damages += HIT_DAMAGES

    var atk_coef = 1 + (damages / 100.0)
    var knockback = ATTACK_KNOCKBACK * atk_coef
    var hit_direction = (attacker.position - position).normalized()
    self.hit_force = Vector2(-hit_direction.x * knockback, -knockback / 4)

func knockback():
    """Knockback"""
    self.velocity += Vector2(SHIELD_KNOCKBACK * -direction, 0)

func respawn():
    """Respawn player."""
    self.reset()
    self.position = self.spawn_position

func reset():
    """Reset player state."""
    self.velocity = Vector2()
    self.hit_force = Vector2()
    self.on_air_time = 100
    self.direction = 1
    self.damages = 0

    self.jumping = false
    self.falling = false
    self.attacking = false
    self.blocking = false
    self.is_hit = false

    self.can_attack = true
    self.can_shield = true

    self.prev_jump_pressed = false
    self.prev_attack_pressed = false
    self.prev_shield_pressed = false

    self.animation_player.play("idle")

#################
# Event callbacks

func _on_attack_cooldown_timer_timeout():
    self.can_attack = true

func _on_shield_cooldown_timer_timeout():
    self.can_shield = true

func _on_animation_finished(anim_name):
    if anim_name == "hit":
        self.is_hit = false
    elif anim_name == "attacking":
        self.attack_cooldown_timer.start()
        self.attacking = false
        self.velocity.x = ATTACK_SPEED * -direction
    elif anim_name == "shield":
        self.shield_cooldown_timer.start()
        self.blocking = false

func _on_screen_exited():
    self.emit_signal("died")
    self.respawn()
