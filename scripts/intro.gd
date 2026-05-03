extends Control

func _ready():
	# Garante que o vídeo comece a tocar
	$VideoPlayer.play()

func _on_video_player_finished():
	# Quando o vídeo acabar, vai para o menu principal
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event):
	# Se o jogador clicar ou apertar qualquer tecla, pula a intro
	if event is InputEventMouseButton or event is InputEventKey:
		if event.is_pressed():
			_on_video_player_finished()
