extends Control

@onready var player_1_score: Label = $Player1Score
@onready var player_2_score: Label = $Player2Score
@onready var ball: Area2D = $"../Ball"

signal game_over

var score_left = 0
var score_right = 0
var max_score = 2

func _ready() -> void:
	player_1_score.text = str(score_left)
	player_2_score.text = str(score_right)

func add_point_left():
	score_left += 1
	player_1_score.text = str(score_left)
	if score_left > max_score:
		game_over.emit()
		score_left = 0

func add_point_right():
	score_right += 1
	player_2_score.text = str(score_right)
	if score_right > max_score:
		game_over.emit()
		score_right = 0

func _on_ball_out_of_bounds(side) -> void:
	if side == -1:
		add_point_right()
	else:
		add_point_left()
