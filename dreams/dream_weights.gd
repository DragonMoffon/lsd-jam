class_name WeightModifiers extends Resource

@export_category("Weights")
@export var integrity: float = 0.0
@export var lucidity: float = 0.0

@export_category("Methods")
enum ModificationMethod {Add, Multiply, Set}
@export var integrity_method: ModificationMethod = ModificationMethod.Add
@export var lucidity_method: ModificationMethod = ModificationMethod.Add

func update_weights(save: SaveData):
	save.integrity = _apply_method(integrity_method, save.integrity, integrity)
	save.lucidity = _apply_method(lucidity_method, save.lucidity, lucidity)

func _apply_method(method: ModificationMethod, base: float, modification: float) -> float:
	match method:
		ModificationMethod.Add:
			return base + modification
		ModificationMethod.Multiply:
			return base * modification
		ModificationMethod.Set:
			return modification
	return base
