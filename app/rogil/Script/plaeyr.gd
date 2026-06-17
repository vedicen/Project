extends Entity
class_name Plaeyr

@onready var animation_player: AnimationPlayer = $Idle/AnimationPlayer
@onready var camerapoint: Node3D = $camerapoint
@onready var camera_3d: Camera3D = $camerapoint/Camera3D
@onready var idle: Node3D = $Idle
@onready var area_dmg: Area3D = $Area_dmg
@onready var collision_shape_dmg: CollisionShape3D = $Area_dmg/CollisionShapeDMG

@onready var control: Control = $Control
@onready var panel: Panel = $Control/Panel
@onready var v_box_container: VBoxContainer = $Control/Panel/VBoxContainer
@onready var upgete_1: Button = $Control/Panel/VBoxContainer/Upgete1
@onready var upgete_2: Button = $Control/Panel/VBoxContainer/Upgete2
@onready var upgete_4: Button = $Control/Panel/VBoxContainer/Upgete4
@onready var upgete_5: Button = $Control/Panel/VBoxContainer/Upgete5
@onready var hp_bar: ProgressBar = $ProgressBar

const WALK_SPEED = 20.0   # нормальная скорость (подберите на глаз)
const ACCELERATION = 10.0
const FRICTION = 20.0
const MOUSE_SENSITIVITY = 0.003
const CAMERA_MIN_PITCH = -60.0
const CAMERA_MAX_PITCH = 75.0
const MODEL_ROTATION_SPEED = 10.0
const ATTACK_RANGE = 2.5

var camera_pitch: float = 0.0
var enemies_in_range: Array[Entity] = []

# Player.gd (дописать в _ready)
func _ready() -> void:
	
	super._ready()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("Idle")
	add_to_group("player")
	area_dmg.body_entered.connect(_on_attack_area_entered)
	area_dmg.body_exited.connect(_on_attack_area_exited)
	update_hp_bar()
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

	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#_attack_nearest_enemy()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	_handle_movement(delta)
	_update_animation()
	move_and_slide()
	
	# Атака ПОСЛЕ движения
	if enemies_in_range.size() > 0:
		print("Врагов в зоне: ", enemies_in_range.size())   # строка A
		var nearest = _get_nearest_enemy()
		if nearest:
			print("Атакую ", nearest.name)      
			print("попытка атаки")            # строка B
			try_attack(nearest)
	
func _get_nearest_enemy() -> Entity:
	if enemies_in_range.size() == 0:
		return null
	return enemies_in_range[0]  
func _handle_movement(delta: float) -> void:
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
		# Целевая скорость — направление умноженное на WALK_SPEED
		var target_velocity = direction * WALK_SPEED
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)
				# Поворот модели (оставляем как есть)
		var local_dir := global_transform.basis.inverse() * direction
		var target_angle := atan2(local_dir.x, local_dir.z)
		idle.rotation.y = lerp_angle(idle.rotation.y, target_angle, delta * MODEL_ROTATION_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

func _update_animation() -> void:
	var moving := Vector2(velocity.x, velocity.z).length() > 0.1
	if moving:
		if animation_player.current_animation != "Walking/mixamo_com":
			animation_player.play("Walking/mixamo_com")
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")

func _attack_nearest_enemy() -> void:
	var nearest: Entity = null
	var nearest_dist := ATTACK_RANGE

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not (enemy is Entity):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist <= nearest_dist:
			nearest_dist = dist
			nearest = enemy

	if nearest:
		try_attack(nearest)




func _on_attack_area_entered(body: Node3D) -> void:
	print("В зону вошло: ", body.name)
	if body is Entity and body.is_in_group("enemy"):
		if body not in enemies_in_range:
			enemies_in_range.append(body)

func _on_attack_area_exited(body: Node3D) -> void:
	print("В зону вышло: ", body.name)   # исправлено сообщение
	if body is Entity and body.is_in_group("enemy"):
		enemies_in_range.erase(body)
		
		
func update_hp_bar():
	if hp_bar:
		hp_bar.max_value = get_max_hp()
		hp_bar.value = current_hp
		
func take_damage(amount: int) -> void:
	super.take_damage(amount)
	update_hp_bar()
func _handle_regen(delta: float) -> void:
	super._handle_regen(delta)
	update_hp_bar()
func level_up() -> void:
	panel.show()
	super.level_up()
	update_hp_bar()
	
		
		
		
