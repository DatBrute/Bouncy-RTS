extends Control

var spectator_list_ids = []
var player_list_ids = []

func _ready():
	# Called every time the node is added to the scene.
	gamestate.connection_failed.connect(_on_connection_failed)
	gamestate.connection_succeeded.connect(_on_connection_success)
	gamestate.player_list_changed.connect(refresh_lobby)
	gamestate.map_changed.connect(refresh_map)
	gamestate.game_ended.connect(_on_game_ended)
	gamestate.game_error.connect(_on_game_error)
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			arguments[argument.lstrip("--")] = null
	if arguments.has("host"):
		print("hosting")
		_on_host_pressed()
	elif arguments.has("join"):
		assert(arguments["join"] != null, "join supplied without an ip")
		print("joining")
		$Connect/IPAddress.text = arguments["join"]
		_on_join_pressed()



func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	_switch_to_players()

	var player_name = $Connect/Name.text
	gamestate.host_game(player_name)
	refresh_lobby()


func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		print("invalid name")
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	gamestate.join_game(ip, player_name)


func _on_connection_success():
	_switch_to_players()

func _switch_to_players():
	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""
	$Players/MapSelect.clear()
	for map in $"/root/gamestate".maps:
		map = map.trim_prefix("res://edit/maps/current/")
		$Players/MapSelect.add_item(map)


func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")


func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func refresh_lobby():
	var players = gamestate.players
	$Players/SpectatorList.clear()
	$Players/PlayerList.clear()
	spectator_list_ids = []
	player_list_ids = []
	var highest_side = 0
	var k = players.keys()
	k.sort()
	for id in k:
		var p = players[id]
		var side = p.side
		if side == 0:
			$Players/SpectatorList.add_item(p.name + (" (You)" if p.id == multiplayer.get_unique_id() else ""))
			spectator_list_ids.append(id)
		elif side >= highest_side:
			highest_side = p.side
	$Players/SpectatorList.add_item("Click here to spectate")
	spectator_list_ids.append(null)
	for side in range(1, gamestate.map_info.player_count + 1):
		var side_player = null
		for p in players.values():
			if p.side == side:
				side_player = p
				break
		if side_player == null:
			$Players/PlayerList.add_item("Click here to join")
			player_list_ids.append(null)
		else:
			$Players/PlayerList.add_item(side_player.name + (" (You)" if side_player.id == multiplayer.get_unique_id() else ""))
			player_list_ids.append(side_player.id)
	
	$Players/Start.disabled = false

func refresh_map(index):
	$Players/MapSelect.selected = index

func _on_map_select_item_selected(index):
	gamestate.rpc("set_map", index)

func _on_start_pressed():
	gamestate.rpc("begin_game")


func _on_player_list_item_selected(index):
	var my_id = multiplayer.get_unique_id()
	if my_id != 1 and player_list_ids[index] == null:
		gamestate.rpc("become_side", my_id, index + 1)

func _on_spectator_list_item_selected(index):
	var my_id = multiplayer.get_unique_id()
	if my_id != 1 and spectator_list_ids[index] == null:
		gamestate.rpc("become_spectator", my_id)
