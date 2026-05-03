extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui_end: Control = $UIEnd
@onready var btn_som: TextureButton = $VBoxVolume/BtnSom
@onready var slider_volume: VSlider = $VBoxVolume/SliderVolume

func _ready():
	ui_end.visible = false
	animation_player.play("tutorial_sequence")
	
	# Configurar música
	$MusicaFundo.finished.connect(func(): $MusicaFundo.play())
	$MusicaFundo.play()
	
	# Conectar sinais de áudio
	btn_som.pressed.connect(_ao_clicar_som)
	slider_volume.value_changed.connect(_ao_alterar_volume)

func _ao_clicar_som() -> void:
	slider_volume.visible = not slider_volume.visible

func _ao_alterar_volume(valor: float) -> void:
	var db = linear_to_db(valor)
	if valor <= 0.05:
		db = -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_tutorial_finished():
	# Chamado via AnimationPlayer no final da track
	ui_end.visible = true

func _on_btn_continuar_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_btn_repetir_pressed():
	ui_end.visible = false
	animation_player.play("tutorial_sequence")
