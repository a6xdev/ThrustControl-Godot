extends Node
class_name PIDController

var _error_prev:float = 0.0
var _integral:float = 0.0

func update(error:float, delta:float, settings:Vector3) -> float:
	if abs(error) < 0.01: 
		return 0.0
	
	# P - Proporcional
	var p_out = error * settings.x
	
	# I - Integral
	_integral += error * delta
	var i_out = _integral * settings.y
	
	# D - Derivativo
	var error_diff = (error - _error_prev) / delta
	var d_out = error_diff * settings.z

	_error_prev = error
	return p_out + i_out + d_out
