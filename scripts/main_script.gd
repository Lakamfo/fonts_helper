extends Control

onready var selecter = $bg/default_font
onready var settings_menu = $settings_menu
onready var file_select = $select_font_popup
onready var dir_select = $select_export_folder
onready var example_dyfont = preload("res://example_font.tres")
onready var panel  = preload("res://scenes/info_panel.tscn") 
onready var container = $rename_box/v_container
onready var save_progress = $save_progress
onready var load_preset = $settings_menu/load_preset
onready var export_bt = $bg/export
onready var anim_tween = Tween.new()
onready var fade_animation = $fade_anim/animation_player
onready var language_selecter = $settings_menu/language

export (Dictionary) var default_preset = {"1":"arial.ttf","2":"arialbd.ttf","3":"SourceSansPro-Bold.ttf","4":"SourceSansPro-It.ttf","5":"SourceSansPro-Light.ttf","6":"SourceSansPro-Regular.ttf","7":"SourceSansPro-Semibold.ttf"}
var standart_path : String = OS.get_executable_path().get_base_dir() + "/assets/default_fonts"
var preset_path : String  = OS.get_executable_path().get_base_dir() + "/preset.txt"
var export_fonts_path : String  = OS.get_executable_path().get_base_dir() + "/export"
var debug : Bool = OS.is_debug_build()
export (bool) var force_debug = false

onready var ui = {
	"reload":$bg/reload,
	"export":$bg/export,
	"dragNdrop":$bg/dragNdrop,
	"select_folder":$bg/select_folder,
	"add_font":$bg/add_font,
	"or_l":$bg/_or,
	"open_settings_tip":$open_settings_tip,
	"load_preset":$settings_menu/load_preset,
	"save_as_preset":$settings_menu/save_preset,
	"restore_preset":$settings_menu/restore_preset
	}

var fonts : Array = []
var added_fonts_names : Array = []
var languages : Array = []
var languages_names : Array = []
var last_dropped_index : int = 0
var loaded_fonts : Array = []
var file = File.new()
var names : Array = []
var number : int = 0

func _ready() -> void:
	if get_tree().connect("files_dropped", self, "dragNdrop"):
		pass
	
	if debug or force_debug:
		standart_path = "res://debug_files/default_fonts/"
		preset_path = "res://debug_files/preset.txt"
		export_fonts_path = "res://debug_files/export"
	
	fade_animation.get_parent().show()
	fade_animation.play("fade")
	add_child(anim_tween)
	dir_select.current_dir = OS.get_executable_path().get_base_dir()
	
	var file_opener = File.new()
	var default_fonts = Directory.new()
	var localisation_finder = Directory.new()
	
	if default_fonts.open(standart_path) == OK:
		default_fonts.list_dir_begin()
		var file_font = default_fonts.get_next()
		
		while file_font != '':
			if '.ttf' in file_font.to_lower():
				var path_string = standart_path + "/" +str(file_font)
				file_opener.open(path_string, file_opener.READ)
				added_fonts_names.push_front(file_font)
				fonts.push_front(path_string)
				loaded_fonts.push_front(load(path_string))
			file_font = default_fonts.get_next()
		
		default_fonts.list_dir_begin()
		file_font = default_fonts.get_next()
		while file_font != '':
			if '.otf' in file_font.to_lower():
				var path_string = standart_path + "/" + str(file_font)
				file_opener.open(path_string, file_opener.READ)
				added_fonts_names.push_front(file_font)
				fonts.push_front(path_string)
				loaded_fonts.push_front(load(path_string))
			file_font = default_fonts.get_next()
	
	print($bg.localisation_path)
	if localisation_finder.open($bg.localisation_path) == OK:
		localisation_finder.list_dir_begin()
		var language_file = localisation_finder.get_next()
		while language_file != '':
			if '.txt' in language_file.to_lower():
				languages_names.push_front(language_file.split(".")[0])
				var path_string = $bg.localisation_path + str(language_file)
				languages.push_front(path_string)
				file_opener.open(path_string, file_opener.READ)
			language_file = localisation_finder.get_next()
	
	
	for i in languages.size():
		language_selecter.add_item(str(languages_names[i]),i)
		language_selecter.text = $bg.get_language()
	
	for i in fonts.size():
		selecter.add_item(str(added_fonts_names[i]),i)
	
	yield($bg,"load_preset")
	load_preset.pressed = $bg._load_preset
	read_preset()

#Open settings and change fullscreen
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_F2 and event.is_pressed():
			settings_menu.popup_centered()
		if event.scancode == KEY_F11 and event.is_pressed():
			OS.window_fullscreen = !OS.window_fullscreen

func read_preset():
	if not $bg._load_preset:
		return
	
	var _file = File.new()
	_file.open(preset_path,_file.READ)
	var text = _file.get_as_text()
	var json = parse_json(text)
	
	
	for i in json.keys():
		var instance = panel.instance()
		container.add_child(instance)
		instance.line_edit.text = json.get(i)
		instance.label.text = str(number + 1)
		number += 1

func write_fonts():
	export_bt.hide()
	save_progress.show()
	var progress = 0
	var _dir = Directory.new()
	var panels = container.get_children()
	
	for i in panels:
		names.push_front(i.line_edit.text)
	
	for i in names.size():
		yield(get_tree().create_timer(0.1,false),"timeout")
		anim_tween.interpolate_property(save_progress,"value",save_progress.value,progress,0.2,Tween.TRANS_CIRC)
		anim_tween.start()
		progress += 1
		_dir.copy(fonts[last_dropped_index],export_fonts_path + "/" + names[i])
	
	export_bt.show()
	save_progress.hide()
	progress = 0

func add_font_bt() -> void:
	file_select.popup_centered()

func add_font(path: String) -> void:
	print(path)
	loaded_fonts.push_front(load(path))
	example_dyfont.set("font_data",loaded_fonts[loaded_fonts.find(load(path))])
	fonts.push_front(path)
	last_dropped_index = loaded_fonts.find(load(path))

func font_selected(index: int) -> void:
	example_dyfont.set("font_data",loaded_fonts[index])
	last_dropped_index = index

func dragNdrop(files=[], _screen = 0) -> void:
	if '.ttf' or '.otf' in files[0]:
		loaded_fonts.push_front(load(files[0]))
		example_dyfont.set("font_data",loaded_fonts[0])
		print_debug("File dropped from",files[0])
		fonts.push_front(files[0])
		last_dropped_index = fonts.find(files[0])

func export() -> void:
	write_fonts()

func add_bt() -> void:
	var instance = panel.instance()
	container.add_child(instance)
	instance.label.text = str(get_tree().get_nodes_in_group("panel").size())

func export_folder_selected(dir: String) -> void:
	export_fonts_path = dir

func folder_select() -> void:
	dir_select.popup_centered()

func reload_bt() -> void:
	if get_tree().reload_current_scene():
		pass

