extends Node2D

@onready var ball: Area2D = $Ball
@onready var paddle: Area2D = $Paddle
@onready var paddle_2: Area2D = $Paddle2
@onready var score: Control = $Score
@onready var press_space: Label = $Back/PressSpace

var is_demo_mode = true

func _input(event):
	if is_demo_mode and event.is_action_pressed("ui_accept"):
		set_demo_mode(false)
		score.reset()
		
func _on_score_game_over() -> void:
	set_demo_mode(true)

func set_demo_mode(value):
	is_demo_mode = value
	ball.is_demo_mode = value
	paddle.is_demo_mode = value
	paddle_2.is_demo_mode = value
	press_space.visible = value
