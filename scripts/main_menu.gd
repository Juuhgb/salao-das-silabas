extends Control

# Variável estática para persistir durante a execução do jogo (sessão)
static var tutorial_visto := false

@onready var btn_som: TextureButton = $VBoxVolume/BtnSom
@onready var slider_volume: VSlider = $VBoxVolume/SliderVolume

func _ready():
	# Conectar sinais de áudio
	btn_som.pressed.connect(_ao_clicar_som)
	slider_volume.value_changed.connect(_ao_alterar_volume)
	
	# Garantir que a música toque e reinicie ao acabar
	$MusicaFundo.finished.connect(func(): $MusicaFundo.play())
	$MusicaFundo.volume_db = -15
	$MusicaFundo.play()

func _ao_clicar_som() -> void:
	slider_volume.visible = not slider_volume.visible

func _ao_alterar_volume(valor: float) -> void:
	var db = linear_to_db(valor)
	if valor <= 0.05:
		db = -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_btn_jogar_pressed():
	if not tutorial_visto:
		tutorial_visto = true
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
