# Godot Image Stream

Grabs the current scene view and streams it over a WebSocket.

Built and tested on Godot 4.1.2.

## Configuration

- Update the `ui_right`, `ui_left`, `ui_up`, and `ui_down` in the "Input Map" to include the "Physical" version of the right, left, up, and down keys.
- Adjust `ImageSenderTimer`'s `Wait Time` as needed.
