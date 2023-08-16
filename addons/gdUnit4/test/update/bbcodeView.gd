extends Control

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")
const GdMarkDownReader := preload("res://addons/gdUnit4/src/update/GdMarkDownReader.gd")
const GdUnitUpdateClient := preload("res://addons/gdUnit4/src/update/GdUnitUpdateClient.gd")

@onready var _input :TextEdit = $HSplitContainer/TextEdit
@onready var _text :RichTextLabel = $HSplitContainer/RichTextLabel

@onready var _update_client :GdUnitUpdateClient = $GdUnitUpdateClient

var _md_reader := GdMarkDownReader.new()


func _ready():
	_md_reader.set_http_client(_update_client)
	var source := GdUnitTools.resource_as_string("res://addons/gdUnit4/test/update/resources/markdown_example.txt")
	_input.text = source
	await set_bbcode(source)


func set_bbcode(text :String) :
	var bbcode = await _md_reader.to_bbcode(text)
	_text.clear()
	_text.append_text(bbcode)
	_text.queue_redraw()


func _on_TextEdit_text_changed():
	await set_bbcode(_input.get_text())


func _on_RichTextLabel_meta_clicked(meta :String):
	var properties = str_to_var(meta)
	prints("meta_clicked", properties)
	if properties.has("url"):
		OS.shell_open(properties.get("url"))


func _on_RichTextLabel_meta_hover_started(meta :String):
	var properties = str_to_var(meta)
	prints("hover_started", properties)
	if properties.has("tool_tip"):
		_text.set_tooltip(properties.get("tool_tip"))


func _on_RichTextLabel_meta_hover_ended(_meta :String):
	_text.set_tooltip("")
