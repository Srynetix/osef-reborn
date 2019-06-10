extends "res://actors/player/BaseInputController.gd"

########################
# AI Input Controller

const PLATFORM_THRESHOLD = 60

var direction = -1  # left
var has_attacked = false

func _init(player).(player):
    pass

func _detect_player():
    var detection_threshold = Vector2(direction * 50, 0)
    var space_state = player.get_world_2d().direct_space_state
    var result = space_state.intersect_ray(player.global_position, player.global_position + detection_threshold, [player])
    if result:
        var collider = result.collider
        if collider.is_in_group("Player"):
            return collider

    return null

func _detect_platform():
    var detection_threshold = Vector2(0, 100)
    var space_state = player.get_world_2d().direct_space_state
    var result = space_state.intersect_ray(player.global_position, player.global_position + detection_threshold, [player])
    if result:
        var shape_idx = result.shape
        var collider = result.collider
        if not collider.is_in_group("Platform"):
            return null

        var owner_idx = collider.shape_find_owner(shape_idx)
        var shape = collider.shape_owner_get_shape(owner_idx, shape_idx)

        var collider_position = collider.position
        var shape_extents = shape.extents

        # Position is at the middle
        var max_x = collider_position.x + shape_extents.x
        var min_x = collider_position.x - shape_extents.x

        var platform_data = {
            "name": collider.name,
            "min_x": min_x,
            "max_x": max_x
        }

        return platform_data

    return null

func move_on_platform():
    # Reset movements
    left_pressed = false
    right_pressed = false

    # Get platform
    var platform_limits = _detect_platform()
    if platform_limits == null:
        return

    # Debug
    # print("Platform detected: " + JSON.print(platform_limits))

    # Move depending on direction
    if direction == -1:
        left_pressed = true
    elif direction == 1:
        right_pressed = true

    if player.position.x > platform_limits.max_x - PLATFORM_THRESHOLD:
        # print("RIGHT EDGE DETECTED")
        direction = -1
    elif player.position.x < platform_limits.min_x + PLATFORM_THRESHOLD:
        # print("LEFT EDGE DETECTED")
        direction = 1

func attack_player():
    # Reset attack
    attack_pressed = false

    # Get player
    var player = _detect_player()
    if player == null:
        return

    # Press attack!
    attack_pressed = true

    # Toggle attack
    if has_attacked:
        attack_pressed = false
        has_attacked = false
    elif attack_pressed:
        has_attacked = true

func process_input(delta):
    move_on_platform()
    attack_player()
