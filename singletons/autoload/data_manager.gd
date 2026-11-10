extends Node

const SETTINGS_PATH = "user://settings.res"
@export var settings_override: Settings
@export var save_override: SaveData
var settings: Settings
var save: SaveData

signal settings_loaded
signal save_loaded

func _ready():
	_load_settings()
	if settings.load_automatically and settings.active_save_path != "" and settings.active_save_path != null:
		if save_override != null:
			load_save(save_override)
		else:
			load_save_path(settings.active_save_path)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_settings()
		
func _load_settings():
	if settings != null:
		settings.changed.disconnect(_save_settings)
	
	if settings_override != null:
		settings = settings_override
	elif ResourceLoader.exists(SETTINGS_PATH, "Settings"):
		settings = ResourceLoader.load(SETTINGS_PATH)
	else:
		settings = Settings.new()
		_save_settings()
	
	settings.changed.connect(_save_settings)
	settings_loaded.emit()

func _save_settings():
	var save_path = SETTINGS_PATH if settings_override == null else settings.resource_path
	ResourceSaver.save(settings, save_path)
	
func load_save(save_data: SaveData) -> bool:
	if settings == null:
		push_warning("No settings resource created cannot load save")
		return false
	if save != null:
		write_save(save)
	save = save_data
	settings.active_save_path = save.resource_path
	
	# TODO: Actual save loading steps
	
	save_loaded.emit()
	return true
	
func load_save_path(save: String) -> bool:
	if not ResourceLoader.exists(save, "SaveData"):
		push_warning("Invalid Save Path '%s'. Was it moved or deleted?" % save)
		return false
	return load_save(ResourceLoader.load(save))

func write_save(save_data: SaveData):
	ResourceSaver.save(save_data, save_data.resource_path)
