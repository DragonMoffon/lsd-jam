class_name Util

static func smerp(a: float, b: float, dt: float, h: float) -> float:
	return a + (b - a) * exp(-dt / h)

static func smerp2d(a: Vector2, b: Vector2, dt: float, h: float) -> Vector2:
	return a + (b - a) * exp(-dt / h)

static func smerp3d(a: Vector3, b: Vector3, dt: float, h: float) -> Vector3:
	return a + (b - a) * exp(-dt / h)
