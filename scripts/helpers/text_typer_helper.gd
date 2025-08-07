extends Node

class_name TextTyperHelper

var label: RichTextLabel
var full_text: String
var speed: float = 0.05
var parent_node: Node

static func start(parent: Node, text: String, _speed: float = 0.2) -> TextTyperHelper:
	var typer = TextTyperHelper.new()
	typer.full_text = text
	typer.speed = _speed
	typer.parent_node = parent
	parent.add_child(typer)
	typer._init_label()
	typer._start_typing()
	return typer

func _init_label() -> void:
	label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(label)

func _start_typing() -> void:
	label.clear()
	await _type_text()

func _type_text() -> void:
	var current := ""
	for i in full_text.length():
		current += full_text[i]
		if !is_instance_valid(label): return
		label.text = current
		print(current)
		await get_tree().create_timer(speed).timeout

func skip() -> void:
	if !is_instance_valid(label): return
	label.text = full_text

func _exit_tree() -> void:
	if is_instance_valid(label):
		label.queue_free()
