extends Area2D

signal out_of_bounds

@onready var paddle: AudioStreamPlayer = $"../Audio/Paddle"
@onready var wall: AudioStreamPlayer = $"../Audio/Wall"
@onready var score: AudioStreamPlayer = $"../Audio/Score"
@onready var timer: Timer = $Timer


@export var ball_size = 14
@export var base_speed = 300

var is_demo_mode = true:
	set(value):
		is_demo_mode = value
		if is_demo_mode == false:
			ball_start()

var speed
var ball_x_start = 40
var ball_y_start_space = 20
var screen_size
var direction = Vector2.ZERO
var hit_count = 0
var side = randi_range(0, 1)

func _ready() -> void:
	$ColorRect.size = Vector2(ball_size, ball_size)
	$ColorRect.position = Vector2(-ball_size/2.0, -ball_size/2.0)
	$CollisionShape2D.shape.size = Vector2(ball_size, ball_size)
	
	screen_size = get_viewport_rect().size
	ball_start()

func _physics_process(delta: float) -> void:
	if (position.y - ball_size/2.0) < 0:
		direction.y = abs(direction.y)
		play_sound(wall)
	if (position.y + ball_size/2.0) > screen_size.y:
		direction.y = -abs(direction.y)
		play_sound(wall)
	position += direction * speed * delta

	if position.x < -ball_size/2.0:
		if is_demo_mode == false:
			play_sound(score)
			out_of_bounds.emit(-1)
			side = 0
			ball_start()
		if is_demo_mode == true:
			direction.x *= -1
	if position.x > screen_size.x + ball_size/2.0:
		if is_demo_mode == false:
			play_sound(score)
			out_of_bounds.emit(1)
			side = 1
			ball_start()
		if is_demo_mode == true:
			direction.x *= -1

func ball_start():
	speed = base_speed
	hit_count = 0
	hide()
	
	direction = Vector2.ZERO
	
	var init_x
	var init_y
	if side == 0:
		init_x = screen_size.x / 2 - ball_x_start
	else:
		init_x = screen_size.x / 2 + ball_x_start
	init_y = randi_range(ball_y_start_space, screen_size.y - ball_y_start_space)
	position = Vector2(init_x, init_y)
	
	timer.start()	

func _on_area_entered(area: Area2D) -> void:
	hit_count += 1
	play_sound(paddle)
	if hit_count == 4:
		speed = base_speed * 1.5
	if hit_count == 12:
		speed = base_speed * 2.2
		
	var paddle_pos = area.position
	var paddle_len = area.paddle_len
	var percent = clamp((position.y - (paddle_pos.y - paddle_len/2)) / paddle_len, 0, 1)
	percent = int(percent * 8)
	
	match percent:
		0:
			direction.y = -.9
		1:
			direction.y = -.6
		2:
			direction.y = -.5
		3:
			direction.y = -.1
		4:
			direction.y = .1
		5:
			direction.y = .3
		6:
			direction.y = .6
		7:
			direction.y = .9
	
	direction.x *= -1

func _on_timer_timeout() -> void:
	show()
	if side == 0:
		direction = Vector2.LEFT.rotated(randf_range(-.5, .5))
	if side == 1:
		direction = Vector2.RIGHT.rotated(randf_range(-.5, .5))

func play_sound(player):
	if is_demo_mode:
		return
	player.play()
