extends ColorRect

export (String) var settings_path = OS.get_executable_path().get_base_dir() + "/settings.txt"
export (String) var localisation_path = OS.get_executable_path().get_base_dir() + "/assets/localisation/"

var _load_preset = true
var localisation_buffer = {}
var settings_buffer = {}
var locale = "en"
var _file_settings = File.new()
var _file_preset = File.new()

signal load_preset

func _ready() -> void:
	yield(get_parent(),"ready")
	if get_parent().debug or get_parent().force_debug:
		settings_path = "res://settings.txt"
		localisation_path = "res://assets/localisation/"
	
	_file_settings.open(settings_path,File.READ)
	print(settings_path)
	var _text = _file_settings.get_as_text()
	var settings_json = parse_json(_text)
	settings_buffer = settings_json
	
	_file_settings.close()
	
	_load_preset = settings_buffer.load_preset
	emit_signal("load_preset")
	
	_file_preset.open(localisation_path + locale + ".txt",File.READ)
	
	var localisation_text = _file_preset.get_as_text()
	localisation_buffer = parse_json(localisation_text)
	
	load_locale(locale)

func load_locale(_locale: String):
	var _file = File.new()
	
	_load_preset = settings_buffer.load_preset
	_file.open(localisation_path + _locale + ".txt",File.READ)
	print(localisation_path + _locale + ".txt")
	
	var text = _file.get_as_text()
	var json = parse_json(text)
	localisation_buffer = json
	
	_localisate()

func get_language():
	return locale

func store_settings():
	var write_settings = {
	"language":locale,
	"load_preset":_load_preset
	}
	
	var js = to_json(write_settings)
	_file_settings.open(settings_path,File.WRITE_READ)
	_file_settings.store_line(js)
	_file_settings.close()

func _localisate():
	var _ui = get_parent().ui
	
	_ui.reload.text = localisation_buffer.reload
	
	_ui.dragNdrop.text = localisation_buffer.dragNdrop
	
	_ui.add_font.text = localisation_buffer.add_font
	
	_ui.export.text = localisation_buffer.export
	
	_ui.select_folder.text = localisation_buffer.select_folder
	
	_ui.or_l.text = localisation_buffer.or_l
	
	_ui.open_settings_tip.text = localisation_buffer.open_settings_tip
	
	_ui.load_preset.text = localisation_buffer.load_preset
	
	_ui.save_as_preset.text = localisation_buffer.save_as_preset
	
	_ui.restore_preset.text = localisation_buffer.restore_preset

func load_preset_toggled(button_pressed: bool) -> void:
	_load_preset = button_pressed

func _settings_menu_popup_hide() -> void:
	store_settings()

func _restore_presset_pressed() -> void:
	var _dir = Directory.new()
	_dir.remove(get_parent().preset_path)
	_file_preset.open(get_parent().preset_path,_file_preset.WRITE_READ)
	_file_preset.store_line(to_json(get_parent().default_preset))
	_file_preset.close()

func _save_presset_pressed() -> void:
	var panels = get_parent().container.get_children()
	var dict = {}
	for i in panels.size():
		dict[str(i + 1)] = panels[i].line_edit.text
	var _dir = Directory.new()
	_dir.remove(get_parent().preset_path)
	_file_preset.open(get_parent().preset_path,_file_preset.WRITE_READ)
	_file_preset.store_line(to_json(dict))
	_file_preset.close()

func _on_language_item_selected(index: int) -> void:
	locale = get_parent().languages_names[index]
	load_locale(locale)
