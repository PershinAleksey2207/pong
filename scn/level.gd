extends Node2D

@onready var ball: Area2D = $Ball
@onready var paddle: Area2D = $Paddle
@onready var paddle_2: Area2D = $Paddle2
@onready var score: Control = $Score
@onready var press_space: Label = $Back/PressSpace

var is_demo_mode = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		switch_demo_vars()
		score.player_1_score.text = str(0)
		score.player_2_score.text = str(0)
		
func _on_score_game_over() -> void:
	switch_demo_vars()

func switch_demo_vars():
	is_demo_mode = !is_demo_mode
	ball.is_demo_mode = !ball.is_demo_mode
	paddle.is_demo_mode = !paddle.is_demo_mode
	paddle_2.is_demo_mode = !paddle_2.is_demo_mode
	press_space.visible = !press_space.visible
	
