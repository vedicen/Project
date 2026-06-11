extends CharacterBody3D
class_name Plaeyr
@onready var animation_player: AnimationPlayer = $Idle/AnimationPlayer
@onready var camerapoint: Node3D = $camerapoint
@onready var camera_3d: Camera3D = $camerapoint/Camera3D

const SPEED = 5.0
const SPRINT_SPEED = 9.0
const ACCELERATION = 10.0
const FRICTION = 20.0  # было 12.0
const MOUSE_SENSITIVITY = 0.003
const CAMERA_MIN_PITCH = -60.0
const CAMERA_MAX_PITCH = 75.0

var camera_pitch: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("Idle")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			camera_pitch = clamp(
				camera_pitch - event.relative.y * MOUSE_SENSITIVITY,
				deg_to_rad(CAMERA_MIN_PITCH),
				deg_to_rad(CAMERA_MAX_PITCH)
			)
			camerapoint.rotation.x = camera_pitch
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			var mode := Input.MOUSE_MODE_VISIBLE \
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED \
				else Input.MOUSE_MODE_CAPTURED
			Input.set_mouse_mode(mode)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)
	_update_animation()
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_movement(delta: float) -> void:
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var cam_basis := camera_3d.global_transform.basis
	var forward := -cam_basis.z
	var right := cam_basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	var direction := (forward * -input_dir.y + right * input_dir.x).normalized()

	if direction.length() > 0.1:
		var target_angle := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)
		velocity.x = move_toward(velocity.x, direction.x * speed, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0, FRICTION * delta)

func _update_animation() -> void:
	# Было > 0.5 — теперь > 0.1 для быстрой реакции
	var moving := Vector2(velocity.x, velocity.z).length() > 0.1
	var sprinting := Input.is_action_pressed("sprint")

	if moving:
		var target := "Run/mixamo_com" if sprinting else "Walking/mixamo_com"
		if animation_player.current_animation != target:
			animation_player.play(target)
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
