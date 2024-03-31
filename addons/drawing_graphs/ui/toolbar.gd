@tool
extends Control

# modes
enum CURSOR_MODE {SELECT_POINTS, ADD_POINTS, DELETE_POINTS, LINK_POINTS, CUT_EDGES, CONFIG}
var current_mode = CURSOR_MODE.SELECT_POINTS

signal cursor_mode_changed(current_mode)

func send_signal():
	emit_signal("cursor_mode_changed", current_mode)

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	$BoxContainer/SelectButton.toggled.connect(on_select_button)
	$BoxContainer/DrawButton.toggled.connect(on_draw_button)
	$BoxContainer/DeleteButton.toggled.connect(on_delete_button)
	$BoxContainer/LinkButton.toggled.connect(on_link_button)
	$BoxContainer/SplitButton.toggled.connect(on_split_button)
	$BoxContainer/ConfigButton.toggled.connect(on_config_button)

func state_machine():
	send_signal()
	match current_mode:
		CURSOR_MODE.SELECT_POINTS:
			$BoxContainer/DrawButton.button_pressed = false
			$BoxContainer/DeleteButton.button_pressed = false
			$BoxContainer/LinkButton.button_pressed = false
			$BoxContainer/SplitButton.button_pressed = false
			$BoxContainer/ConfigButton.button_pressed = false

		CURSOR_MODE.ADD_POINTS:
			$BoxContainer/SelectButton.button_pressed = false
			$BoxContainer/DeleteButton.button_pressed = false
			$BoxContainer/LinkButton.button_pressed = false
			$BoxContainer/SplitButton.button_pressed = false
			$BoxContainer/ConfigButton.button_pressed = false

		CURSOR_MODE.DELETE_POINTS:
			$BoxContainer/SelectButton.button_pressed = false
			$BoxContainer/DrawButton.button_pressed = false
			$BoxContainer/LinkButton.button_pressed = false
			$BoxContainer/SplitButton.button_pressed = false
			$BoxContainer/ConfigButton.button_pressed = false

		CURSOR_MODE.LINK_POINTS:
			$BoxContainer/SelectButton.button_pressed = false
			$BoxContainer/DrawButton.button_pressed = false
			$BoxContainer/DeleteButton.button_pressed = false
			$BoxContainer/SplitButton.button_pressed = false
			$BoxContainer/ConfigButton.button_pressed = false

		CURSOR_MODE.CUT_EDGES:
			$BoxContainer/SelectButton.button_pressed = false
			$BoxContainer/DrawButton.button_pressed = false
			$BoxContainer/DeleteButton.button_pressed = false
			$BoxContainer/LinkButton.button_pressed = false
			$BoxContainer/ConfigButton.button_pressed = false

		CURSOR_MODE.CONFIG:
			$BoxContainer/SelectButton.button_pressed = false
			$BoxContainer/DrawButton.button_pressed = false
			$BoxContainer/DeleteButton.button_pressed = false
			$BoxContainer/LinkButton.button_pressed = false
			$BoxContainer/SplitButton.button_pressed = false


func on_select_button(toggled_on:bool):
	if toggled_on:
		current_mode = CURSOR_MODE.SELECT_POINTS
		state_machine()


func on_draw_button(toggled_on:bool):
	if toggled_on:
		current_mode = CURSOR_MODE.ADD_POINTS
		state_machine()


func on_delete_button(toggled_on:bool):
	if toggled_on:
		current_mode = CURSOR_MODE.DELETE_POINTS
		state_machine()


func on_link_button(toggled_on:bool):
	if toggled_on:
		current_mode = CURSOR_MODE.LINK_POINTS
		state_machine()


func on_split_button(toggled_on:bool):
	if toggled_on:
		current_mode = CURSOR_MODE.CUT_EDGES
		state_machine()


func on_config_button(toggled_on:bool):
	if toggled_on:
		current_mode = CURSOR_MODE.CONFIG
		state_machine()
	