extends CharacterBody3D
class_name Player
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var control: Control = $Control

@onready var animation_player: AnimationPlayer = $skin/AnimationPlayer
@onready var animation_tree: AnimationTree = $skin/AnimationTree
@onready var camera_pivot: Node3D = $camera_pivot

var mouse_sensitivity = 0.003

func _ready():
	control.hidden
	Global.player = self 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	animation_tree.active = true

	print("=== READY ===")
	print("AnimationTree: ", animation_tree)
	print("Active: ", animation_tree.active)
	print("RunValue: ", animation_tree.get("parameters/RunValue/blend_amount"))

func _input(event):
	if event is InputEventMouseMotion:

		# Поворот персонажа
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Поворот камеры
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)

		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):

	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Движение
	var input_dir = Input.get_vector(
	"left",
	"right",
	"up",
	"down"
)
	var direction = ( transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)
).normalized()

	if input_dir.length() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Анимация
	var run_value = 1.0 if input_dir.length() > 0 else 0.0

	if animation_tree.get("parameters/RunValue/blend_amount") != run_value:
		print("RunValue -> ", run_value)

	animation_tree.set("parameters/RunValue/blend_amount", run_value)

	move_and_slide()
func level_up():
	control.show()
