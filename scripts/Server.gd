extends Node

const DEFAUTL_PORT = 8000
const PROTOCOLS = ["demo-chat"]
const IMG_FEED_UPDATE_INTERVAL = 2

@onready var _server : WebSocketServer = $WebSocketServer
@onready var image_sender_timer : Timer = $ImageSenderTimer

# 
# Initiate the server 
# 
func _ready():
	# Setup 
	_server.supported_protocols = PROTOCOLS
	var err = _server.listen(DEFAUTL_PORT)
	
	# Check for error
	if err != OK:
		print("Error listing on port %s" % DEFAUTL_PORT)
		return
	print("Listing on port %s, supported protocols: %s" % [DEFAUTL_PORT, _server.supported_protocols])

# 
# Server signals - Connected via Godot's GUI
# 
func _on_web_socket_server_message_received(peer_id, message):
	print("Server received data from peer %d: %s" % [peer_id, message])
	_server.send(-peer_id, "[%d] Says: %s" % [peer_id, message])

func _on_web_socket_server_client_connected(peer_id):
	var peer : WebSocketPeer = _server.peers[peer_id]
	print("Remote client connected: %d. Protocol: %s" % [peer_id, peer.get_selected_protocol()])
	_server.send(-peer_id, "[%d] connected" % peer_id)
	# Start the timer as soon as a client connects
	image_sender_timer.start()

func _on_web_socket_server_client_disconnected(peer_id):
	var peer : WebSocketPeer = _server.peers[peer_id]
	print("Remote client disconnected: %d. Code: %d, Reason: %s" % [peer_id, peer.get_close_code(), peer.get_close_reason()])
	_server.send(-peer_id, "[%d] disconnected" % peer_id)

# 
# Other signals
# 
func _on_image_sender_timer_timeout():
	# Capture the current view
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	
	# Remove alpha channel and convert to grayscale
	img.convert(Image.FORMAT_L8) # Helps reduce size

	# Resize the image
	img.shrink_x2()
	img.shrink_x2()
	print("Image size: ", img.get_width(), " x ", img.get_height())
	
	var png = img.save_png_to_buffer()
	print("Sending bytes: ", len(png))

	# Broadcast the chunk to all connected clients
	var err = _server.send_broadcast(png)
	if err != OK:
		print("Error: ", err)

