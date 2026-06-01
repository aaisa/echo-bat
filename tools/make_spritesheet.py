#!/usr/bin/env python3
"""
Genera spritesheet de animación del murciélago.

Toma 4 frames individuales y los combina en un spritesheet de 8 frames
(ida y vuelta para loop suave).
"""

from PIL import Image
import os

# Rutas
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES_DIR = os.path.join(BASE_DIR, "assets", "sprites", "player")
OUTPUT_PATH = os.path.join(SPRITES_DIR, "bat_sheet.png")

# Configuración
FRAME_SIZE = 256
FRAME_NAMES = ["bat_anim_1.png", "bat_anim_2.png", "bat_anim_3.png", "bat_anim_4.png"]

def load_and_resize(path: str) -> Image.Image:
    """Carga una imagen y la redimensiona a FRAME_SIZE x FRAME_SIZE manteniendo proporciones."""
    img = Image.open(path).convert("RGBA")

    # Calcular nueva dimensión manteniendo aspect ratio
    width, height = img.size
    if width > height:
        new_width = FRAME_SIZE
        new_height = int((height / width) * FRAME_SIZE)
    else:
        new_height = FRAME_SIZE
        new_width = int((width / height) * FRAME_SIZE)

    img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Crear canvas cuadrado y centrar la imagen
    canvas = Image.new("RGBA", (FRAME_SIZE, FRAME_SIZE), (0, 0, 0, 0))
    offset_x = (FRAME_SIZE - new_width) // 2
    offset_y = (FRAME_SIZE - new_height) // 2
    canvas.paste(img_resized, (offset_x, offset_y), img_resized)

    return canvas

def main():
    print(f"Generando spritesheet en {OUTPUT_PATH}...")

    # Cargar los 4 frames
    frames = []
    for name in FRAME_NAMES:
        path = os.path.join(SPRITES_DIR, name)
        if not os.path.exists(path):
            print(f"ERROR: No existe {path}")
            return 1
        frames.append(load_and_resize(path))
        print(f"  ✓ Cargado {name}")

    # Crear secuencia ping-pong: 1,2,3,4,4,3,2,1
    sequence = frames + list(reversed(frames))

    # Crear spritesheet horizontal: 8 frames × 256px = 2048px ancho
    spritesheet = Image.new("RGBA", (FRAME_SIZE * 8, FRAME_SIZE), (0, 0, 0, 0))

    for i, frame in enumerate(sequence):
        spritesheet.paste(frame, (i * FRAME_SIZE, 0), frame)

    # Guardar
    spritesheet.save(OUTPUT_PATH, "PNG")
    print(f"✓ Spritesheet guardado: {OUTPUT_PATH}")
    print(f"  Dimensiones: 2048×256 px (8 frames de 256×256)")

    return 0

if __name__ == "__main__":
    exit(main())
