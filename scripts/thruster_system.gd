extends Marker3D
class_name ThrusterSystem

@onready var engine_flame: GPUParticles3D = $engine_flame

@export var pid_settings:Vector3
@export var max_force:float = 500.0

var strenght_history:PackedFloat32Array = []
var current_strength:float = 0.0

func apply_thrust(power_percent:float, body:ActorDrone) -> void:
	current_strength = power_percent
	strenght_history.push_back(power_percent)
	if strenght_history.size() > 100:
		strenght_history.remove_at(0)
		
	var strength = clamp(power_percent, 0.0, 1.0) * max_force
	var direction = global_transform.basis.y
	var relative_pos = global_position - body.global_position
	var intensity = clamp(strength / max_force, 0.0, 1.0)
	body.apply_force(direction * strength, relative_pos)
	
	engine_flame.emitting = power_percent > 0.1
	var mat = engine_flame.process_material as ParticleProcessMaterial
	if mat:
		mat.initial_velocity_min = 2.0 * intensity
		mat.initial_velocity_max = 5.0 * intensity
		mat.scale_min = 0.5 + (0.5 * intensity)

func get_current_strength() -> float:
	return current_strength

func update_debug() -> void:
	ImGui.PlotLinesEx(name + " strenght", strenght_history, strenght_history.size(), 0, (name + " strenght"), 0.0, 500.0, Vector2(0.0, 60.0))
