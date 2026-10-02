class_name RunnerPhysicsConfig
extends Resource
## Design values from docs/05-technical/05-physics-collision-generation.md §2, compiled once to integers.

@export var gravity := 1000.0
@export var hold_gravity_scale := 0.6
@export var fall_gravity_scale := 1.15
@export var jump_velocity := 260.0
@export var max_hold_time := 0.22
@export var max_fall_speed := 420.0
@export var coyote_time := 0.08
@export var jump_buffer := 0.12
@export var stomp_bounce_velocity := 220.0
@export var stomp_max_hold_time := 0.13


func compile() -> JumpPhysics:
	var physics := JumpPhysics.new()
	physics.gravity = Fixed.acceleration(gravity)
	physics.hold_gravity = Fixed.acceleration(gravity * hold_gravity_scale)
	physics.fall_gravity = Fixed.acceleration(gravity * fall_gravity_scale)
	physics.jump_velocity = Fixed.velocity(jump_velocity)
	physics.max_fall_speed = Fixed.velocity(max_fall_speed)
	physics.max_hold_ticks = Fixed.ticks(max_hold_time)
	physics.coyote_ticks = Fixed.ticks(coyote_time)
	physics.buffer_ticks = Fixed.ticks(jump_buffer)
	physics.stomp_velocity = Fixed.velocity(stomp_bounce_velocity)
	physics.stomp_max_hold_ticks = Fixed.ticks(stomp_max_hold_time)
	return physics
