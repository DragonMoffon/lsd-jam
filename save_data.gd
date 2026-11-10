class_name SaveData extends Resource


@export_category("Dream Weights")
signal integrity_changed(old: float, new: float); @export_custom(PROPERTY_HINT_ONESHOT, "") var integrity: float = 0.0:
	set(value): 
		var old = integrity
		integrity = value
		integrity_changed.emit(old, value)
	get:
		return integrity

signal lucidity_changed(old: float, new: float); @export_custom(PROPERTY_HINT_ONESHOT, "") var lucidity: float = 0.0: 
	set(value): 
		var old = lucidity
		lucidity = value
		lucidity_changed.emit(old, value)
	get:
		return integrity
		
@export_category("Dream")
@export var last_link: DreamLink

@export_category("Player")
@export var collected_fragments: Array[DreamFragment]
