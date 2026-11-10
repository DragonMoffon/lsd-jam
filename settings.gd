class_name Settings extends Resource

@export_category("Audio") # TODO: link settings volume sliders to audio buses
@export var main: float = 1.0 

@export_category("Saves")
@export_file_path("*.tres", "*.res") var active_save_path: String
@export var load_automatically: bool
