class_name SaveData extends Resource


@export_category("Dream Weights")
signal integrity_changed(old: float, new: float); @export_custom(PROPERTY_HINT_ONESHOT, "") var integrity: float = 0.0:
	set(value): 
		if integrity == value:
			return # No reason to modify the value and emit the signal
		var old = integrity
		integrity = value
		integrity_changed.emit(old, value)
		emit_changed()
	get:
		return integrity

signal lucidity_changed(old: float, new: float); @export_custom(PROPERTY_HINT_ONESHOT, "") var lucidity: float = 0.0: 
	set(value): 
		if lucidity == value:
			return # No reason to modify the value and emit the signal
		var old = lucidity
		lucidity = value
		lucidity_changed.emit(old, value)
		emit_changed()
	get:
		return lucidity
		
@export_category("Dream")
@export var last_link: DreamLink

@export_category("Player")
@export var collected_fragments: Array[DreamFragment]
		
