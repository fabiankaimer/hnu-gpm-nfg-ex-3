extends Control

@onready var name_input: LineEdit = $VBoxContainer/NameInput
@onready var ip_input: LineEdit = $VBoxContainer/IPInput
@onready var port_input: LineEdit = $VBoxContainer/PortInput
@onready var host_button: Button = $VBoxContainer/HBoxContainer/HostButton
@onready var join_button: Button = $VBoxContainer/HBoxContainer/JoinButton

const DEFAULT_PORT: int = 9999
const DEFAULT_MAX_PLAYERS: int = 8

func _ready() -> void:
	# Defaultwerte
	ip_input.text = "127.0.0.1"
	port_input.text = str(DEFAULT_PORT)
	name_input.text = "Player" + str(int(Time.get_unix_time_from_system()) % 1000)
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	
func _on_host_pressed() -> void:
	Player.player_name = name_input.text.strip_edges()
	var port = int(port_input.text)
	var max_clients = DEFAULT_MAX_PLAYERS

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, max_clients)
	if err != OK:
		push_error("Server start fehlgeschlagen: %s" % err)
		return
	else:
		print("Server erfolgreich gestartet")

	# Setzt den Peer global (bleibt beim Szenenwechsel erhalten)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://chat/Chat.tscn")

func _on_join_pressed() -> void:
	Player.player_name = name_input.text.strip_edges()
	var ip = ip_input.text.strip_edges()
	var port = int(port_input.text)

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, port)
	if err != OK:
		push_error("Verbindung fehlgeschlagen: %s" % err)
		return
	else:
		print("Server erfolgreich beigetreten")

	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://chat/Chat.tscn")
