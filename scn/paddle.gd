extends Area2D

@export var player_id = -1
@export var paddle_len = 80
@export var paddle_width = 8
var screen_height
var death_zone = 30

var is_demo_mode = true:
	set(value):
		is_demo_mode = value
		paddle_demo_switch()

var speed = 700

func _ready() -> void:
	$ColorRect.size = Vector2(paddle_width, paddle_len)
	$ColorRect.position = Vector2(-paddle_width/2.0, -paddle_len/2.0)
	$CollisionShape2D.shape.size = Vector2(paddle_width, paddle_len)
	screen_height = get_viewport_rect().size.y
	
	paddle_demo_switch()

func _physics_process(delta: float) -> void:
	if player_id == 1:
		if Input.is_action_pressed("p1_up"):
			position.y -= speed * delta
		if Input.is_action_pressed("p1_down"):
			position.y += speed * delta
	if player_id == 2:
		if Input.is_action_pressed("p2_up"):
			position.y -= speed * delta
		if Input.is_action_pressed("p2_down"):
			position.y += speed * delta
	
	position.y = clamp(position.y, paddle_len/2.0 + death_zone, screen_height - paddle_len/2.0)
	
func paddle_demo_switch():
	visible = not is_demo_mode
	$CollisionShape2D.set_deferred("disabled", is_demo_mode)
