extends Control

# =============================================================================
# SALÃO DAS SÍLABAS — Lógica principal do jogo
# Método ABACADA: associação entre imagem, sílaba e palavra
# Godot 4.6 | GDScript
#
# Os nós da interface estão definidos em scenes/game.tscn.
# Este script apenas controla a lógica do jogo e referencia os nós.
# =============================================================================

# --- Dados das palavras ---
# Cada entrada: palavra completa, sílabas, qual sílaba esconder, emoji (imagem placeholder)
var palavras := [
	{"palavra": "CASA", "silabas": ["CA", "SA"], "esconder": 0, "imagem": "res://assets/images/casa.png"},
	{"palavra": "BALA", "silabas": ["BA", "LA"], "esconder": 0, "imagem": "res://assets/images/bala.png"},
	{"palavra": "MALA", "silabas": ["MA", "LA"], "esconder": 0, "imagem": "res://assets/images/mala.png"},
	{"palavra": "FACA", "silabas": ["FA", "CA"], "esconder": 0, "imagem": "res://assets/images/faca.png"},
	{"palavra": "FADA", "silabas": ["FA", "DA"], "esconder": 0, "imagem": "res://assets/images/fada.png"},
]

# Sílabas extras para compor os distratores nas unhas
var distratores := ["DA", "TA", "RA", "CA"]

# Paleta de esmaltes: rosa como protagonista + cores complementares
var cores_esmalte := [
	Color("#FF69B4"), # Rosa-choque — identidade do jogo
	Color("#FF1493"), # Deep pink
	Color("#FF6B6B"), # Coral
	Color("#DA70D6"), # Lilás / orquídea
	Color("#FFD700"), # Amarelo ouro
	Color("#87CEEB"), # Azul celeste
]

# --- Estado do jogo ---
var indice_atual   := 0  # Índice da palavra atual
var unhas_pintadas := 0  # Contador de palavras acertadas
var silabas_nas_unhas: Array = []
var cor_acerto_atual: Color

var indices_unhas_livres := [0, 1, 2, 3, 4] # Unhas não pintadas ainda

# --- Referências a nós únicos (via @onready, lidos da cena) ---
@onready var victory_screen  : Control     = $VictoryScreen
@onready var imagem_palavra  : TextureRect = $GameContainer/PainelImagem/ImagemPalavra
@onready var label_palavra   : Label       = $GameContainer/LabelPalavra
@onready var audio_voz       : AudioStreamPlayer = $AudioVoz

@onready var btn_som         : TextureButton = $VBoxVolume/BtnSom
@onready var slider_volume   : VSlider = $VBoxVolume/SliderVolume

# Arrays de nós numerados — preenchidos em _ready() com get_node()
var botoes_unhas: Array = []
var indicadores : Array = []


# =============================================================================
# INICIALIZAÇÃO
# =============================================================================

func _ready() -> void:
	silabas_nas_unhas = ["", "", "", "", ""]
	
	# Preencher o array das 5 unhas e conectar os sinais de clique
	for i in 5:
		var btn := get_node("GameContainer/CenterMao/ControlMao/Unha%d" % i)
		botoes_unhas.append(btn)
		btn.pressed.connect(_ao_clicar_unha.bind(i))

	# Preencher o array dos indicadores de progresso (um por palavra)
	for i in palavras.size():
		indicadores.append(get_node("HBoxProgresso/Bolinha%d" % i))

	# Conectar o botão "Jogar de novo" da tela de vitória
	$VictoryScreen/BtnReiniciar.pressed.connect(_reiniciar_jogo)

	# Garantir que a tela de vitória começa escondida
	victory_screen.visible = false

	# Iniciar o jogo na primeira palavra
	_carregar_palavra()

	# Garantir que a música toque e reinicie ao acabar
	$MusicaFundo.finished.connect(func(): $MusicaFundo.play())
	$MusicaFundo.play()

	# Conectar botões de volume
	btn_som.pressed.connect(_ao_clicar_som)
	slider_volume.value_changed.connect(_ao_alterar_volume)


# =============================================================================
# ÁUDIO
# =============================================================================

func _ao_clicar_som() -> void:
	slider_volume.visible = not slider_volume.visible

func _ao_alterar_volume(valor: float) -> void:
	var db = linear_to_db(valor)
	if valor <= 0.05:
		db = -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)


# =============================================================================
# LÓGICA DO JOGO
# =============================================================================

# Carrega a palavra atual e distribui as sílabas nas unhas
func _carregar_palavra() -> void:
	if indice_atual >= palavras.size():
		_mostrar_vitoria()
		return

	var dados: Dictionary = palavras[indice_atual]

	# Escolher o esmalte desta rodada
	cor_acerto_atual = cores_esmalte[indice_atual % cores_esmalte.size()]

	# Atualizar a imagem da palavra via load() dinâmico
	imagem_palavra.texture = load(dados["imagem"])

	# Tocar o áudio da palavra completa
	var caminho_palavra = "res://assets/audio/%s.mp3" % dados["palavra"].to_lower()
	if ResourceLoader.exists(caminho_palavra):
		audio_voz.stream = load(caminho_palavra)
		audio_voz.play()

	# Montar a palavra com lacuna: sílaba escondida vira "___"
	var silabas: Array = dados["silabas"]
	var partes := []
	for i in silabas.size():
		partes.append("___" if i == dados["esconder"] else silabas[i])
	label_palavra.text = " - ".join(partes)

	# Apenas monta as opções, as unhas antigas continuam pintadas
	_montar_opcoes_unhas(dados)



# Distribui 1 sílaba correta + 4 distratores embaralhados nas 5 unhas
func _montar_opcoes_unhas(dados: Dictionary) -> void:
	var esconder: int   = dados["esconder"]
	var correta: String = dados["silabas"][esconder]

	var opcoes := [correta]

	# Priorizar as sílabas das outras palavras como distratores (mais pedagógico)
	for p in palavras:
		var s: String = p["silabas"][esconder]
		if s != correta and not opcoes.has(s):
			opcoes.append(s)

	# Completar com distratores genéricos, se faltar para as unhas livres
	for d in distratores:
		if opcoes.size() >= indices_unhas_livres.size():
			break
		if not opcoes.has(d):
			opcoes.append(d)

	# Cortar se passou do limite (só por segurança)
	opcoes = opcoes.slice(0, indices_unhas_livres.size())
	opcoes.shuffle()

	# Aplica os nomes APENAS nas unhas que ainda não foram pintadas:
	for id_livre in indices_unhas_livres:
		var syl = opcoes.pop_back()
		silabas_nas_unhas[id_livre] = syl
		botoes_unhas[id_livre].get_node("Label").text = syl
		botoes_unhas[id_livre].disabled = false


# Restaura o estilo "sem esmalte" em todas as unhas
func _resetar_unhas() -> void:
	for btn in botoes_unhas:
		_aplicar_estilo_base(btn)


# Estilo base de uma unha: textura branca pura original
func _aplicar_estilo_base(btn: TextureButton) -> void:
	btn.self_modulate = Color(1, 1, 1, 1)


# =============================================================================
# FEEDBACK
# =============================================================================

func _ao_clicar_unha(indice: int) -> void:
	var dados: Dictionary = palavras[indice_atual]
	var correta: String   = dados["silabas"][dados["esconder"]]
	var silaba_clicada: String = silabas_nas_unhas[indice]

	# Tocar o áudio da sílaba (feedback sonoro imediato)
	var caminho_silaba = "res://assets/audio/%s.mp3" % silaba_clicada.to_lower()
	if ResourceLoader.exists(caminho_silaba):
		audio_voz.stream = load(caminho_silaba)
		audio_voz.play()

	if silaba_clicada == correta:
		_feedback_acerto(indice)
	else:
		_feedback_erro(indice)


func _feedback_acerto(indice: int) -> void:
	# Pintar a unha com o esmalte da rodada (usando self_modulate para não pintar o texto)
	botoes_unhas[indice].self_modulate = cor_acerto_atual

	# Bloquear todas as unhas provisoriamente (serão liberadas na prox rodada)
	for btn in botoes_unhas:
		btn.disabled = true

	# Tira da lista de livres para ela não ter o texto alterado na próxima palavra
	indices_unhas_livres.erase(indice)

	# Preencher o espaço vazio com a sílaba na placa principal
	var dados_palavra: Dictionary = palavras[indice_atual]
	label_palavra.text = " - ".join(dados_palavra["silabas"])

	# Feedback visual positivo removido conforme solicitado
	# label_feedback.text = "✨ Muito bem! ✨"
	# label_feedback.add_theme_color_override("font_color", Color("#C2185B"))
	# label_feedback.visible = true

	# Acender o indicador de progresso com a cor do esmalte
	indicadores[indice_atual].color = cor_acerto_atual
	unhas_pintadas += 1

	# Aguarda 0.8s para a sílaba terminar de ser pronunciada
	await get_tree().create_timer(0.8).timeout
	
	# Em seguida, pronuncia a palavra inteira como reforço
	var caminho_palavra = "res://assets/audio/%s.mp3" % dados_palavra["palavra"].to_lower()
	if ResourceLoader.exists(caminho_palavra):
		audio_voz.stream = load(caminho_palavra)
		audio_voz.play()

	# Aguardar mais 1.5s para a criança escutar a palavra, e então ir à próxima
	await get_tree().create_timer(1.5).timeout
	indice_atual += 1
	_carregar_palavra()


func _feedback_erro(indice: int) -> void:
	var btn = botoes_unhas[indice]
	
	# Sinal visual na unha: cor cinza e um efeito de tremor (shake)
	btn.self_modulate = Color(0.7, 0.7, 0.7)
	
	# Criar efeito de tremor (shake) para sinalizar erro melhor na própria unha
	var original_pos = btn.position
	var tween = create_tween()
	for i in 6:
		var offset = Vector2(randf_range(-4, 4), randf_range(-2, 2))
		tween.tween_property(btn, "position", original_pos + offset, 0.04)
	tween.tween_property(btn, "position", original_pos, 0.04)
	
	# Aguardar o efeito e restaurar a cor original
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	_aplicar_estilo_base(btn)



# =============================================================================
# VITÓRIA
# =============================================================================

func _mostrar_vitoria() -> void:
	# Exibir a tela de vitória (visível sobre o GameContainer)
	victory_screen.visible = true


func _reiniciar_jogo() -> void:
	# Resetar estado
	indice_atual      = 0
	unhas_pintadas    = 0
	silabas_nas_unhas = ["", "", "", "", ""]
	indices_unhas_livres = [0, 1, 2, 3, 4]

	# Resetar indicadores de progresso para a cor inicial (apagada)
	for bolinha in indicadores:
		bolinha.color = Color("#FDDDE6")

	# Resetar estilo das unhas
	_resetar_unhas()

	# Esconder tela de vitória e começar do zero
	victory_screen.visible = false
	_carregar_palavra()
