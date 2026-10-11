class_name WoodsTerrainPatch
extends Node2D
## Visual-only moss and shale tiles; the room's WorldBlock remains authoritative for collision.
const TILE_SIZE := 32
const SOURCE_ID := 0
const FILL_VARIATION_SOURCE_ID := 1
const SURFACE_INSET := 15.0

@onready var terrain_layer: TileMapLayer = $TerrainVisuals
var dimensions := Vector2.ZERO
var spectral := false

func configure(at: Vector2, size: Vector2, is_spectral: bool = false) -> void:
	position = at
	dimensions = size
	spectral = is_spectral

func _ready() -> void:
	terrain_layer.position = Vector2(-dimensions.x * 0.5, -dimensions.y * 0.5 - SURFACE_INSET)
	var columns := ceili(dimensions.x / float(TILE_SIZE))
	var rows := ceili(dimensions.y / float(TILE_SIZE))
	var cells: Array[Vector2i] = []
	for y in range(rows):
		for x in range(columns):
			cells.append(Vector2i(x, y))
	terrain_layer.set_cells_terrain_connect(cells, 0, 0, true)
	_add_surface_variation(columns, rows)
	if spectral:
		GameState.realm_changed.connect(_on_realm_changed)
		_on_realm_changed(GameState.is_veil)

func _add_surface_variation(columns: int, rows: int) -> void:
	var room_offset := floori(position.x / float(TILE_SIZE))
	for x in range(1, columns - 1):
		if posmod(absi(hash(Vector2i(x + room_offset * 31, 7))), 5) < 2:
			terrain_layer.set_cell(Vector2i(x, 0), SOURCE_ID, Vector2i(2, 0))
	if rows == 1:
		return
	for y in range(1, rows):
		for x in range(1, columns - 1):
			var variation_seed := absi(hash(Vector2i(x + room_offset * 31, y)))
			if posmod(variation_seed, 8) < 2:
				var atlas_index := posmod(absi(hash(Vector2i(x + room_offset * 17, y + 53))), 16)
				terrain_layer.set_cell(
					Vector2i(x, y),
					FILL_VARIATION_SOURCE_ID,
					Vector2i(atlas_index % 4, atlas_index / 4)
				)
			else:
				var fill_column := 1 + posmod(absi(hash(Vector2i(x + room_offset * 13, y + 91))), 2)
				terrain_layer.set_cell(Vector2i(x, y), SOURCE_ID, Vector2i(fill_column, 1))

func _on_realm_changed(is_veil: bool) -> void:
	terrain_layer.modulate = Color(0.62, 0.88, 1.0, 0.2 if not is_veil else 0.96)
