"""Split the ImageGen atlas into centered, transparent Roblox control sprites."""

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent
CELLS = {
    "left": (0, 0), "right": (1, 0), "gas": (2, 0),
    "brake": (0, 1), "handbrake": (1, 1),
}
CANVAS = 96
GLYPH = 80


def build():
    atlas = Image.open(ROOT / "atlas.png").convert("RGBA")
    width, height = atlas.width // 3, atlas.height // 2
    for name, (col, row) in CELLS.items():
        cropped = atlas.crop((col * width, row * height, (col + 1) * width, (row + 1) * height))
        silhouette = cropped.getchannel("A").point(lambda alpha: 255 if alpha >= 32 else 0)
        bounds = silhouette.getbbox()
        if not bounds:
            raise ValueError(f"Missing {name} silhouette in atlas")
        x0, y0, x1, y1 = bounds
        sprite = cropped.crop((max(0, x0 - 3), max(0, y0 - 3),
                               min(width, x1 + 3), min(height, y1 + 3)))
        sprite.thumbnail((GLYPH, GLYPH), Image.Resampling.LANCZOS)
        output = Image.new("RGBA", (CANVAS, CANVAS))
        output.paste(sprite, ((CANVAS - sprite.width) // 2, (CANVAS - sprite.height) // 2))
        output.save(ROOT / (name + ".png"), optimize=True)


if __name__ == "__main__":
    build()
