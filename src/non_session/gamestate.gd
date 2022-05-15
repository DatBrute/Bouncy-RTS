extends Node

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12



var peer = null

# Name for my player.
var player_name = "The Warrior"


class Player:
	var id: int
	var name: String
	var side = 0 # what units you control, 0 = spectator
	
# Dict of players by id, including self
var players = {}
var maps = []
var map_index
var map_path
var map_info

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal map_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, StringName("register_player"), player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if multiplayer.is_server():
			game_error.emit("Player " + players[id].name + " disconnected")
			end_game()
		else:
			game_error.emit("Player " + players[id].name + " disconnected")
			end_game()
			multiplayer.multiplayer_peer.close_connection()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)

# Callback from SceneTree, only for clients (not server), on successful connection.
func _connected_ok():
	make_player(multiplayer.get_unique_id(), player_name)
	connection_succeeded.emit()


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	game_error.emit("Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	multiplayer.set_multiplayer_peer(null) # Remove peer
	connection_failed.emit()


# Lobby management functions.
@rpc(any_peer)
func register_player(new_player_name):
	var id = multiplayer.get_remote_sender_id()
	if id != 1:
		make_player(id, new_player_name)
	if multiplayer.is_server():
		print("player registered: ", new_player_name)
		rpc_id(id, "after_self_registered", map_index)
		player_list_changed.emit()
	if id != 1 and not multiplayer.is_server() and map_info != null:
		player_list_changed.emit()

# Called from register_player, only for clients (not server)
@rpc
func after_self_registered(index):
	set_map(index)
	player_list_changed.emit()

func unregister_player(id):
	if players.has(id):
		players.erase(id)
		player_list_changed.emit()
	else: 
		print("attempted to unregister the following id but they were not found: ", id)


@rpc(call_local)
func load_world():
	# Change scene.
	var world = load(map_path + "/World.tscn").instantiate()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Lobby").hide()

	get_tree().set_pause(false) # Unpause and unleash the game!


func host_game(new_player_name):
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)
	rpc("set_map", 0)


func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)


func get_player_name():
	return player_name



@rpc(any_peer)
func begin_game():
	if(not multiplayer.is_server()):
		return
	rpc("load_world")


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	game_ended.emit()
	players.clear()
	clear_map()


func _ready():
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)
	maps = dir_contents("res://edit/maps/current")

# https://docs.godotengine.org/en/latest/classes/class_directory.html?highlight=dir_contents
# names of files in the dir, non-recursive (folders are treated as files)
func dir_contents(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var ret = []
		var file_name = dir.get_next()
		while file_name != "":
			ret.append(path + "/" + file_name)
			file_name = dir.get_next()
		return ret
	else:
		push_error("directory not found")

func make_player(id, new_player_name):
	var player = Player.new()
	player.id = id
	player.name = new_player_name
	players[id] = player

@rpc(any_peer, call_local)
func set_map(index):
	map_index = index
	map_path = maps[0] if map_index == -1 else maps[map_index]
	map_info = load(map_path + "/Info.gd").new()
	map_changed.emit(index)

func clear_map():
	map_index = 0
	map_path = null
	map_info = null
	map_changed.emit(map_index)

@rpc(any_peer, call_local)
func become_side(id, side):
	players[id].side = side
	player_list_changed.emit()
	
@rpc(any_peer, call_local)
func become_spectator(id):
	players[id].side = 0
	player_list_changed.emit()

func is_spectator():
	var id = multiplayer.get_unique_id()
	assert(id != 1 or multiplayer.is_server())
	return multiplayer.is_server() or players[id].side == 0

func get_me():
	return players[multiplayer.get_unique_id()]
