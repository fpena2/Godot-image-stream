import websocket

DEFAULT_PORT = 8000
DEFAULT_ADDR = "127.0.0.1"

server_url = f"ws://{DEFAULT_ADDR}:{DEFAULT_PORT}/test"


def on_message(ws, message):
    print("Received message:", message)


def on_error(ws, error):
    print("WebSocket error:", error)


def on_close(ws, close_status_code, close_msg):
    print(
        "Connection closed with status code",
        close_status_code,
        "and message:",
        close_msg,
    )


def on_open(ws):
    print("Connected to the WebSocket server")
    ws.send("Hello, server!")


if __name__ == "__main__":
    ws = websocket.WebSocketApp(
        server_url,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close,
        on_open=on_open,
    )

    ws.run_forever(ping_interval=3, ping_timeout=2)
