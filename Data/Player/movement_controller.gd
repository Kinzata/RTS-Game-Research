class_name MovementController

extends Node2D

func send_curve_movement_to_units(units: Array[Unit], curve: Curve2D):
	var pos_percent = 1.0 / units.size()
	for i in range(units.size()):
		var target_pos_for_unit = curve.sample_baked(i * pos_percent * curve.get_baked_length(), false)
		units[i].move_to(target_pos_for_unit)

# Given a count of units
# Calculated a set of Vector2 points to use for target destinations
func send_movement_to_units(units: Array[Unit], target_pos: Vector2):
	for unit in units:
		var vector = _random_inside_unit_circle() * 13 * (units.size() / 2)
		unit.move_to(target_pos + vector)

func _random_inside_unit_circle() -> Vector2:
	var theta : float = randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf())
