extends RigidBody3D
class_name ActorDrone

@onready var thruster_front: ThrusterSystem = $thrusters/thruster_front
@onready var thruster_back: ThrusterSystem = $thrusters/thruster_back
@onready var thruster_right: ThrusterSystem = $thrusters/thruster_right
@onready var thruster_left: ThrusterSystem = $thrusters/thruster_left
@onready var thruster_down: ThrusterSystem = $thrusters/thruster_down

var pid_altitude := PIDController.new()
var pid_pitch = PIDController.new()
var pid_roll = PIDController.new()

var altitude_error:float = 0.0
var pitch_error:float = 0.0
var roll_error:float = 0.0

var target_height:float = 3.0

const PID_SETTINGS = Vector3(1.0, 0.2, 0.7)

#region GODOT FUNCTIONS
func _ready() -> void:
	pid_altitude = PIDController.new()
	
	await get_tree().create_timer(3.0).timeout
	freeze = false

func _process(delta: float) -> void:
	debug_controller()

func _physics_process(delta: float) -> void:
	if not freeze:
		altitude_controller(delta)
		stabilization_controller(delta)
#endregion

#region CONTROLLERS
func altitude_controller(_delta:float) -> void:
	altitude_error = target_height - global_position.y
	var total_strength:float = pid_altitude.update(altitude_error, _delta, thruster_down.pid_settings) # Esta não é a força do thruster, é a força para equilibrar essa merda
	var altitude_force = (mass * 9.8) * total_strength
	thruster_down.apply_thrust(altitude_force, self)

func stabilization_controller(_delta:float) -> void:
	var forward_vector = global_transform.basis.z
	var right_vector = global_transform.basis.x
	var pitch_rad:float = asin(-forward_vector.y)
	var roll_rad = asin(right_vector.y)
	var base_stabilization = thruster_down.get_current_strength() * 0.1
	
	pitch_error = 0 - pitch_rad
	roll_error = 0 - roll_rad
	
	var corr_pitch = pid_pitch.update(pitch_error, _delta, PID_SETTINGS)
	var corr_roll = pid_roll.update(roll_error, _delta, PID_SETTINGS)
	
	thruster_left.apply_thrust((base_stabilization - corr_roll), self)
	thruster_right.apply_thrust((base_stabilization + corr_roll), self)
	
	thruster_front.apply_thrust((base_stabilization + corr_pitch), self)
	thruster_back.apply_thrust((base_stabilization - corr_pitch), self)

func user_input_controller() -> void:
	pass

func debug_controller() -> void:
	ImGui.Begin("Thrust Data")
	ImGui.Text("Current Altitude: %.2f" % global_position.y)
	ImGui.Separator()
	ImGui.Text("Altitude Error: %.2f" % altitude_error)
	ImGui.Text("Pitch Error: %.2f" % pitch_error)
	ImGui.Text("Roll Error: %.2f" % roll_error)
	ImGui.Separator()
	
	for child:ThrusterSystem in $thrusters.get_children():
		child.update_debug()
	
	ImGui.End()
#endregion
