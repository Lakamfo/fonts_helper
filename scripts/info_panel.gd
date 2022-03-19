extends Panel

onready var line_edit = $LineEdit
onready var label = $LineEdit/Label

func bt_pressed() -> void:
	var main = get_tree().get_nodes_in_group("main")[0]
	main.number -= 1
	queue_free()
