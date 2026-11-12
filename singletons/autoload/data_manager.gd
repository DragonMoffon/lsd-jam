extends Node

const SETTINGS_PATH = "user://settings.res"
@export var settings_override: Settings
@export var save_override: SaveData
@export var duplicate_settings: bool = false
@export var duplicate_save: bool = false
var settings: Settings
var save: SaveData

signal settings_loaded
signal save_loaded

signal integrity_changed(old: float, new: float); func _on_integerity_changed(old: float, new: float): integrity_changed.emit(old, new)
signal lucidity_changed(old: float, new: float);  func _on_lucidity_changed(old: float, new: float): lucidity_changed.emit(old, new)
signal weights_changed

func update_weights(...modifiers: Array):
	if save == null:
		push_warning("No save loaded no weights were updated")
		return
	for modifier in modifiers:
		if modifier.has_method("update_weights"):
			modifier.update_weights(save)
	weights_changed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		save_state()

func _connect_save_signals():
	save.integrity_changed.connect(_on_integerity_changed)
	save.lucidity_changed.connect(_on_lucidity_changed)
	
func _disconnect_save_signals():
	save.integrity_changed.disconnect(_on_integerity_changed)
	save.lucidity_changed.disconnect(_on_lucidity_changed)

func _ready():
	_load_settings()
	if settings.load_automatically:
		if save_override != null:
			load_save(save_override)
		elif settings.active_save_path != "" and settings.active_save_path != null:
			load_save_path(settings.active_save_path)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_state()
			
func save_state():
	_save_settings()
	if save != null:
		write_save(save)
	
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
	 # If we are duplicating the settings then we don't want to actually change what is on disk
	if duplicate_settings:
		return
	var save_path = SETTINGS_PATH if settings_override == null else settings.resource_path
	ResourceSaver.save(settings, save_path)
	
func load_save(save_data: SaveData) -> bool:
	if settings == null:
		push_warning("No settings resource created cannot load save")
		return false
	if save != null:
		write_save(save)
		_disconnect_save_signals()
	save = save_data
	settings.active_save_path = save.resource_path
	_connect_save_signals()
	# TODO: Actual save loading steps
	
	save_loaded.emit()
	return true
	
func load_save_path(save_path: String) -> bool:
	if not ResourceLoader.exists(save_path, "SaveData"):
		push_warning("Invalid Save Path '%s'. Was it moved or deleted?" % save)
		return false
	return load_save(ResourceLoader.load(save_path))

func write_save(save_data: SaveData):
	 # If we are duplicating the save then we don't want to actually change what is on disk
	if duplicate_save:
		return
	ResourceSaver.save(save_data, save_data.resource_path)
