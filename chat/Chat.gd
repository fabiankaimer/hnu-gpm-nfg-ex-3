extends Control

@onready var chat_log: RichTextLabel = $VBoxContainer/ChatLog
@onready var message_input: LineEdit = $VBoxContainer/HBoxContainer/MessageInput
@onready var send_button: Button = $VBoxContainer/HBoxContainer/SendButton

func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	message_input.text_submitted.connect(_on_send_pressed)
	# Verbindung / Trennung erkennen
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# Zeige lokalen Startstatus
	_append_chat_line("[System] Deine ID: %s" % str(multiplayer.get_unique_id()))

func _on_send_pressed():
	var text = message_input.text.strip_edges()
	if text == "":
		return
	var player_name = Player.player_name if Player.player_name != "" else "Player" + str(multiplayer.get_unique_id())
	message_input.text = ""
	# Rufe die RPC auf — die Funktion 'receive_message' ist für alle Peers verfügbar.
	rpc("receive_message", player_name, text, multiplayer.get_unique_id())

# Diese Funktion wird per RPC bei allen Peers ausgeführt.
@rpc("any_peer", "call_local", "reliable")
func receive_message(sender_name: String, text: String, sender_id: int) -> void:
	var now := Time.get_datetime_dict_from_system()
	var display = "[%s] %s: %s" % [
		str(now.hour).pad_zeros(2) + ":" + str(now.minute).pad_zeros(2),
		sender_name,
		text
	]
	print(sender_id)
	_append_chat_line(display)

func _append_chat_line(line: String) -> void:
	chat_log.append_text(line + "\n")
	# chat_log.scroll_vertical = chat_log.get_line_count()  # versucht zum Ende zu scrollen

func _on_peer_connected(id: int) -> void:
	_append_chat_line("[System] Peer verbunden: %d" % id)

func _on_peer_disconnected(id: int) -> void:
	_append_chat_line("[System] Peer getrennt: %d" % id)
