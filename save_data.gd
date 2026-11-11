class_name SaveData extends Resource


@export_category("Dream Weights")
signal integrity_changed(old: float, new: float); @export_custom(PROPERTY_HINT_ONESHOT, "") var integrity: float = 0.0:
	set(value): 
		var old = integrity
		integrity = value
		integrity_changed.emit(old, value)
		emit_changed()
	get:
		return integrity

signal lucidity_changed(old: float, new: float); @export_custom(PROPERTY_HINT_ONESHOT, "") var lucidity: float = 0.0: 
	set(value): 
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

enum UpdateMethod {Add, Multiply, Set}
func update_weights(method: UpdateMethod, integrity_change: float, lucidity_change: float):
	match method:
		UpdateMethod.Add:
			integrity += integrity_change
			lucidity += lucidity_change
		UpdateMethod.Multiply:
			integrity *= integrity_change
			lucidity *= lucidity_change
		UpdateMethod.Set:
			integrity = integrity_change
			lucidity = lucidity_change
		
