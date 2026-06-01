extends Node2D

# Sistema de parallax con 5 capas para fondos de biomas.
# Usa placeholders de color hasta que estén listos los fondos reales.

# Colores placeholder del Bioma 1 (La Entrada: tonos ocres cálidos)
const LAYER_COLORS := [
	Color("#1a0a00"),  # Capa 1 (más lejana): negro rojizo
	Color("#2d1200"),  # Capa 2: marrón muy oscuro
	Color("#3d1f00"),  # Capa 3: marrón oscuro
	Color("#4a2800"),  # Capa 4: marrón medio
	Color("#5c3300"),  # Capa 5 (más cercana): marrón más claro
]

const LAYER_SIZE := Vector2(2560, 720)

func _ready() -> void:
	_setup_placeholder_layers()

func _setup_placeholder_layers() -> void:
	var parallax_bg := $ParallaxBackground

	for i in range(5):
		var layer_name := "Layer%d" % (i + 1)
		var layer: ParallaxLayer = parallax_bg.get_node(layer_name)
		if layer == null:
			continue

		var sprite: Sprite2D = layer.get_node("Sprite2D")
		if sprite == null:
			continue

		# Crear textura placeholder de color sólido
		var img := Image.create(int(LAYER_SIZE.x), int(LAYER_SIZE.y), false, Image.FORMAT_RGBA8)
		img.fill(LAYER_COLORS[i])
		var tex := ImageTexture.create_from_image(img)

		sprite.texture = tex
